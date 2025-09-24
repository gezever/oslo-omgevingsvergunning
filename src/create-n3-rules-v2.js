import { rdfDereferencer } from "rdf-dereference";
import N3 from "n3";
import fs from "fs";
import path from "path";

const prefixen = JSON.parse(fs.readFileSync("source/prefixes.json", "utf8"));

var regexp_ns = new RegExp(".*/ns/.*");

const regexp_langString = new RegExp(".*langString.*");
const regexp_XMLSchema = new RegExp(".*XMLSchema.*");
const regexp_Class = new RegExp(".*#Class.*");
const regexp_blank_node = new RegExp("_:.*|b.*");
const regexp_Literal = new RegExp(".*Literal.*");

const all_rules = "n3/all-rules.n3";
const unsupported_log = "n3/unsupported.log";

/* ---------- Rule templates ---------- */
function domain_rule(property, klasse) {
    return `{ ?x <${property}> ?y } => { ?x a <${klasse}> } .`;
}
function range_rule(property, klasse) {
    return `{ ?x <${property}> ?y } => { ?y a <${klasse}> } .`;
}
function subclass_rule(klasse, superklasse) {
    return `{ ?x a <${klasse}> } => { ?x a <${superklasse}> } .`;
}
function subproperty_rule(property, superproperty) {
    return `{ ?x <${property}> ?y } => { ?x <${superproperty}> ?y } .`;
}
function equivalentClass_rule(A, B) {
    return `{ ?x a <${A}> } => { ?x a <${B}> } .\n{ ?x a <${B}> } => { ?x a <${A}> } .`;
}
function inverseOf_rule(P, Q) {
    return `{ ?x <${P}> ?y } => { ?y <${Q}> ?x } .`;
}
function symmetricProperty_rule(P) {
    return `{ ?x <${P}> ?y } => { ?y <${P}> ?x } .`;
}
function transitiveProperty_rule(P) {
    return `{ ?x <${P}> ?y . ?y <${P}> ?z } => { ?x <${P}> ?z } .`;
}

/* ---------- Helpers ---------- */
function sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
}

function paden(url) {
    const domain = url.split("/")[2].split(".").reverse().join("/");
    let pad = "";
    let turtle = "";
    let notation_3 = "";
    if (regexp_ns.test(url)) {
        pad = url.split("/ns/")[1];
        turtle = [["main/resources", domain, "ns", pad, path.basename(pad)].join("/"), "ttl"].join(".");
        notation_3 = [["main/resources", domain, "ns", pad, path.basename(pad)].join("/"), "n3"].join(".");
    } else {
        const tail = ([x, y, z, ...xs]) => xs;
        pad = tail(url.split("/")).join("/");
        turtle = [["main/resources", domain, pad, path.basename(pad)].join("/"), "ttl"].join(".");
        notation_3 = [["main/resources", domain, pad, path.basename(pad)].join("/"), "n3"].join(".");
    }
    return { pad, turtle, notation_3 };
}

function remap_quad(q) {
    if (q.subject.value) q.subject.id = q.subject.value;
    if (q.object.value) q.object.id = q.object.value;
    if (q.predicate.value) q.predicate.id = q.predicate.value;
    return q;
}

function logUnsupported(message) {
    fs.appendFileSync(unsupported_log, message + "\n");
}

/* ---------- Dereference & conversion ---------- */
async function deref(_url, uri, regexp_uri, regexp_ns, regexp_url, domain, pad, turtle, notation_3) {
    var objects = [];
    var rule_array = [];
    console.log("Dereferencing:", _url);

    try {
        const ttl_writer = new N3.Writer({ format: "text/turtle", prefixes: { ...prefixen } });
        const { data, url } = await rdfDereferencer.dereference(_url);
        console.log("Resolved to:", url);

        data
            .on("data", (quad) => {
                ttl_writer.addQuad(quad);
                quad = remap_quad(quad);

                if (regexp_uri.test(quad.subject.id)) {
                    /* RDFS constructs */
                    if (quad.predicate.id === "http://www.w3.org/2000/01/rdf-schema#domain" && !regexp_blank_node.test(quad.object.id)) {
                        rule_array.push(`# from ${_url}\n` + domain_rule(quad.subject.id, quad.object.id));
                    }
                    if (quad.predicate.id === "http://www.w3.org/2000/01/rdf-schema#range") {
                        if (
                            !regexp_langString.test(quad.object.id) &&
                            !regexp_XMLSchema.test(quad.object.id) &&
                            !regexp_Literal.test(quad.object.id) &&
                            !regexp_blank_node.test(quad.object.id)
                        ) {
                            rule_array.push(`# from ${_url}\n` + range_rule(quad.subject.id, quad.object.id));
                        }
                    }
                    if (quad.predicate.id === "http://www.w3.org/2000/01/rdf-schema#subClassOf") {
                        if (!regexp_Class.test(quad.object.id) && !regexp_blank_node.test(quad.object.id)) {
                            rule_array.push(`# from ${_url}\n` + subclass_rule(quad.subject.id, quad.object.id));
                        }
                    }
                    if (quad.predicate.id === "http://www.w3.org/2000/01/rdf-schema#subPropertyOf") {
                        rule_array.push(`# from ${_url}\n` + subproperty_rule(quad.subject.id, quad.object.id));
                    }

                    /* OWL constructs */
                    if (quad.predicate.id === "http://www.w3.org/2002/07/owl#equivalentClass") {
                        rule_array.push(`# from ${_url}\n` + equivalentClass_rule(quad.subject.id, quad.object.id));
                    }
                    if (quad.predicate.id === "http://www.w3.org/2002/07/owl#inverseOf") {
                        rule_array.push(`# from ${_url}\n` + inverseOf_rule(quad.subject.id, quad.object.id));
                    }
                    if (quad.predicate.id === "http://www.w3.org/2002/07/owl#SymmetricProperty") {
                        rule_array.push(`# from ${_url}\n` + symmetricProperty_rule(quad.subject.id));
                    }
                    if (quad.predicate.id === "http://www.w3.org/2002/07/owl#TransitiveProperty") {
                        rule_array.push(`# from ${_url}\n` + transitiveProperty_rule(quad.subject.id));
                    }

                    /* Unsupported constructs logging */
                    if (quad.predicate.id === "http://www.w3.org/2002/07/owl#disjointWith") {
                        logUnsupported(`Disjointness found: ${quad.subject.id} disjointWith ${quad.object.id}`);
                    }
                    if (
                        [
                            "http://www.w3.org/2002/07/owl#cardinality",
                            "http://www.w3.org/2002/07/owl#minCardinality",
                            "http://www.w3.org/2002/07/owl#maxCardinality",
                        ].includes(quad.predicate.id)
                    ) {
                        logUnsupported(`Cardinality restriction found on ${quad.subject.id}: ${quad.predicate.id} ${quad.object.id}`);
                    }
                }
            })
            .on("error", (error) => console.error(error))
            .on("end", () => {
                if (!fs.existsSync(path.dirname(turtle))) {
                    fs.mkdirSync(path.dirname(turtle), { recursive: true });
                }
                const rules = rule_array.join("\n") + "\n";
                fs.writeFileSync(notation_3, rules);
                fs.appendFileSync(all_rules, "\n" + rules);
                ttl_writer.end((error, result) => fs.writeFileSync(turtle, result));
                iterate(Array.from(new Set(objects)).sort());
            });
    } catch (error) {
        console.log("No such URL:", _url);
        const text = [["main/error", domain, "ns", pad, path.basename(pad)].join("/"), "txt"].join(".");
        if (!fs.existsSync(path.dirname(text))) {
            fs.mkdirSync(path.dirname(text), { recursive: true });
        }
        fs.writeFileSync(text, error.message);
    }
}

/* ---------- Iteration ---------- */
async function iterate(array) {
    const uris = array.filter((n) => n.startsWith("http"));
    for (let uri of uris) {
        await sleep(1000);
        var url = uri.split("#")[0];
        var regexp_uri = new RegExp(uri);
        var regexp_url = new RegExp(url);
        const domain = url.split("/")[2].split(".").reverse().join("/");
        let p = paden(url);
        const pad = p.pad;
        const turtle = p.turtle;
        const notation_3 = p.notation_3;
        deref(url, uri, regexp_uri, regexp_ns, regexp_url, domain, pad, turtle, notation_3);
    }
}

/* ---------- Start point ---------- */
const my_url = "http://www.w3.org/ns/dcat#";
iterate([my_url]);
