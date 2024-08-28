import pkg from 'pg';
const { Client } = pkg;
import jsonld from "jsonld";
import {RoxiReasoner} from "roxi-js";
import N3 from 'n3';
import fs from "fs";
import rdfDataset from "@rdfjs/dataset";
import { dbConfig } from './utils/dbconfig.js';
import validate from './utils/shacl_validation.js';
//import add_graph from './utils/triples_to_rdf.js';


// const dbConfig = {
//     user: '****',
//     password: '****',
//     host: '****',
//     port: '****',
//     database: '****'
// };

console.log = function() {}

const sortLines = str => Array.from(new Set(str.split(/\r?\n/))).sort().join('\n');
const reasoner = RoxiReasoner.new();
const context = JSON.parse(fs.readFileSync('source/context_oslo.json'));
const prefixes = JSON.parse(fs.readFileSync('source/prefixes.json'));
const client = new Client(dbConfig);

await client.connect();

const klassen = ['activiteit_locatie','activiteit', 'handeling', 'zaak']//
for (let klasse of klassen) {
    const res = await client.query("select * from b_omv_oslo.virtuoso where klasse = " + "'" + klasse + "' limit 100");
    for(var i = 0; i < res.rows.length; i++){
        let json_ld = Object.assign({},res.rows[i].body , {"@context": context})
        fs.writeFileSync('/tmp/radar_oslo' + klasse + i + '.jsonld', JSON.stringify(json_ld, null, 4));
        let rdf = await jsonld.toRDF(json_ld, { format: "application/n-quads" })
        reasoner.add_abox(rdf);
    }
}

reasoner.add_rules(fs.readFileSync('n3/omgevingsvergunning-rules.n3', 'utf8'));
reasoner.add_rules(fs.readFileSync('n3/perceel-rules.n3', 'utf8'));
reasoner.add_rules(fs.readFileSync('n3/cpsv-rules.n3', 'utf8'));
reasoner.add_rules(fs.readFileSync('n3/frbr-core-20050810-rules.n3', 'utf8'));
reasoner.add_rules(fs.readFileSync('n3/adms-rules.n3', 'utf8'));

reasoner.materialize();
const ttl_writer = new N3.Writer({ format: 'text/turtle' , prefixes: prefixes });
const rdf = await sortLines(reasoner.get_abox_dump())
//const rdf = await add_graph(rdf, '<https://github.com/>')
const dataset = rdfDataset.dataset()
const parser = new N3.Parser();
parser.parse(
    rdf,
    (error, quad) => {
        if (quad) {
            ttl_writer.addQuad(quad);
            dataset.add(quad);
        }
        else
            (async () => {
               // if (await validate(shapes, dataset)) {
                ttl_writer.end((error, result) => fs.writeFileSync('results/dwh_mapping/radar_oslo.ttl', result));
                const report = await validate(dataset);
                fs.writeFileSync('results/dwh_mapping/shacl_report.ttl', report)
              //  }
            })()
    });

await client.end();



