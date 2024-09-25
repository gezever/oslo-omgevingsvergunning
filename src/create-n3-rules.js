import { rdfDereferencer } from "rdf-dereference" ;
import N3 from 'n3';
import fs from "fs";
import path from "path";

const prefixen = JSON.parse(fs.readFileSync('source/prefixes.json', "utf8"));

var regexp_ns = new RegExp('/ns/')

const all_rules = 'n3/all-rules.n3'

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

function domain_rule(property, klasse){
    return '{ ?x <' + property + '> ?y } => { ?x a <' + klasse + '> } .'
}

function range_rule(property, klasse){
    return '{ ?x <' + property + '> ?y } => { ?y a <' + klasse + '> } .'
}

function subclass_rule(klasse, superklasse){
    return '{ ?x a <' + klasse + '> } => { ?x a <' + superklasse + '> } .'
}

function subproperty_rule(property, superproperty){
    return '{ ?x <' + property + '> ?y } => { ?x <' + superproperty + '> ?y  } .'
}

function paden(url){
    const domain = url.split('/')[2].split('.').reverse().join('/');
    let pad = ''
    let turtle = ''
    let notation_3 = ''
    if (regexp_ns.test(url)) {
        pad = url.split('/ns/')[1]
        turtle = [['main/resources', domain, 'ns', pad, path.basename(pad)].join('/'), 'ttl'].join('.')
        notation_3 = [['main/resources', domain, 'ns', pad, path.basename(pad)].join('/'), 'n3'].join('.')
    }
    else {
        const tail = ([x,y,z,...xs]) => xs;
        pad = tail(url.split('/')).join('/')
        turtle = [['main/resources', domain, pad, path.basename(pad)].join('/'), 'ttl'].join('.')
        notation_3 = [['main/resources', domain, pad, path.basename(pad)].join('/'), 'n3'].join('.')
    }
    return {"pad": pad, "turtle": turtle, "notation_3": notation_3}
}

async function deref(_url, uri, regexp_uri, regexp_ns, regexp_url, domain,  pad, turtle, notation_3) {
    var objects = [];
    var rule_array = [];
    console.log(_url);
    try {
        const ttl_writer = new N3.Writer({ format: 'text/turtle', prefixes: Object.assign({}, prefixen) });
        const { data , url } = await rdfDereferencer.dereference(_url);
        console.log(url);
        data.on('data', (quad) => {
            ttl_writer.addQuad(quad);
           if (regexp_uri.test(quad.subject.id) || regexp_uri.test(quad.subject.value)) {
                if (quad.predicate.id === "http://www.w3.org/2000/01/rdf-schema#domain") {
                    rule_array.push(domain_rule(quad.subject.id,  quad.object.id ))
                    if (!regexp_uri.test(quad.object.id)) {
                        objects.push(quad.object.id)
                    }
                } else if (quad.predicate.value === "http://www.w3.org/2000/01/rdf-schema#domain") {
                   rule_array.push(domain_rule(quad.subject.value,  quad.object.value ))
                   if (!regexp_uri.test(quad.object.value)) {
                       objects.push(quad.object.value)
                   }
               }                ;
                if (quad.predicate.id === "http://www.w3.org/2000/01/rdf-schema#range") {
                    rule_array.push(range_rule(quad.subject.id, quad.object.id))
                    if (!regexp_uri.test(quad.object.id)) {
                        objects.push(quad.object.id)
                    }
                    ;
                } else if (quad.predicate.value === "http://www.w3.org/2000/01/rdf-schema#range") {
                   rule_array.push(range_rule(quad.subject.value, quad.object.value))
                   if (!regexp_uri.test(quad.object.value)) {
                       objects.push(quad.object.value)
                   }
                   ;
               }
               ;
                if (quad.predicate.id === "http://www.w3.org/2000/01/rdf-schema#subClassOf") {
                    rule_array.push(subclass_rule(quad.subject.id, quad.object.id))
                    if (!regexp_uri.test(quad.object.id)) {
                        objects.push(quad.object.id)
                    }
                    ;
                }else if (quad.predicate.value === "http://www.w3.org/2000/01/rdf-schema#subClassOf") {
                   rule_array.push(subclass_rule(quad.subject.value, quad.object.value))
                   if (!regexp_uri.test(quad.object.value)) {
                       objects.push(quad.object.value)
                   }
                   ;
               };
                if (quad.predicate.id === "http://www.w3.org/2000/01/rdf-schema#subPropertyOf") {
                    rule_array.push(subproperty_rule(quad.subject.id, quad.object.id))
                    if (!regexp_uri.test(quad.object.id)) {
                        objects.push(quad.object.id)
                    }
                    ;
                }else if (quad.predicate.value === "http://www.w3.org/2000/01/rdf-schema#subPropertyOf") {
                   rule_array.push(subproperty_rule(quad.subject.value, quad.object.value))
                   if (!regexp_uri.test(quad.object.value)) {
                       objects.push(quad.object.value)
                   }
                   ;
               }

          }
        })
        .on('error', (error) => console.error(error))
        .on('end', () => {
            if (!fs.existsSync(path.dirname(turtle))){
                fs.mkdirSync(path.dirname(turtle), { recursive: true });
            }
            fs.writeFileSync(notation_3, rule_array.join('\n'));
            fs.appendFileSync(all_rules, '\n' + rule_array.join('\n') + '\n');
            ttl_writer.end((error, result) => fs.writeFileSync(turtle, result));
            iterate(Array.from(new Set(objects)).sort())
        });
    }
    catch(error) {
        console.log('no such ' + _url);
        const text = [['main/error', domain, 'ns', pad, path.basename(pad)].join('/'), 'txt'].join('.')
        if (!fs.existsSync(path.dirname(text))){
            fs.mkdirSync(path.dirname(text), { recursive: true });
        }
        fs.writeFileSync(text, error.message)
    }
}

async function iterate(uris) {
    for (let uri of uris) {
        await sleep(1000)
        var url = uri.split('#')[0];
        var regexp_uri = new RegExp(uri)
        var regexp_url = new RegExp(url)
        const domain = url.split('/')[2].split('.').reverse().join('/');
        let p = paden(url)
        const pad = p.pad
        const turtle = p.turtle
        const notation_3 = p.notation_3
        deref(url, uri, regexp_uri, regexp_ns, regexp_url, domain,  pad, turtle, notation_3)
    }
}
const my_url = 'http://purl.org/dc/terms/FileFormat'
//const my_url = 'http://xmlns.com/foaf/0.1/homepage'
//const my_url = 'https://data.vlaanderen.be/ns/omgevingsvergunning'
iterate([my_url])
