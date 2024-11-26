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

const context = JSON.parse(fs.readFileSync('source/context_oslo.json'));
const prefixes = JSON.parse(fs.readFileSync('source/prefixes.json'));
const client = new Client(dbConfig);

await client.connect();
let count = await client.query('select count(*) from b_omv_oslo.virtuoso');
//count.rows[0].count
let limit = 1000
for (let offset = 760000; offset <  900000 ; offset += limit) {
//for (let offset = 0; offset <  count.rows[0].count ; offset += limit) {
    try {
        const reasoner = RoxiReasoner.new();
        //console.log(i)
        const res = await client.query("select * from b_omv_oslo.virtuoso " + " OFFSET " + offset + " LIMIT " + limit);
        for(var i = 0; i < res.rows.length; i++){
            let json_ld = Object.assign({},res.rows[i].body , {"@context": context})
            //fs.writeFileSync('/tmp/radar_oslo'  + i + '.jsonld', JSON.stringify(json_ld, null, 4));
            let rdf = await jsonld.toRDF(json_ld, { format: "application/n-quads" })
            reasoner.add_abox(rdf);
        }
        // reasoner.add_rules(fs.readFileSync('n3/extra-rules.n3', 'utf8'));
        // reasoner.add_rules(fs.readFileSync('n3/dcterms-rules.n3', 'utf8'));
        // reasoner.add_rules(fs.readFileSync('n3/omgevingsvergunning-rules.n3', 'utf8'));
        // reasoner.add_rules(fs.readFileSync('n3/geosparql-rules.n3', 'utf8'));
        // reasoner.add_rules(fs.readFileSync('n3/cpsv-rules.n3', 'utf8'));
        // reasoner.add_rules(fs.readFileSync('n3/legacy_locn-rules.n3', 'utf8'));
        // reasoner.add_rules(fs.readFileSync('n3/frbr-core-20050810-rules.n3', 'utf8'));

        reasoner.add_rules(fs.readFileSync('n3/adms-rules.n3', 'utf8'));
        reasoner.add_rules(fs.readFileSync('n3/all-rules.n3', 'utf8'));

        reasoner.materialize();
        const ttl_writer = new N3.Writer({ format: 'text/turtle' , prefixes: prefixes });
        const rdf = await sortLines(reasoner.get_abox_dump())
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
                        ttl_writer.end((error, result) => fs.writeFileSync('/tmp/radar_oslo_' + offset + '.ttl', result));
                        //const report = await validate(dataset);
                        //fs.writeFileSync('results/dwh_mapping/shacl_report.ttl', report)
                        //  }
                    })()
            });
        reasoner.free()

    } catch (err) {
        fs.appendFileSync('/tmp/errors.log', err.message);
    }
}


await client.end();



