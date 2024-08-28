import rdf from '@zazuko/env-node'
import validate from './utils/shacl_validation.js';
import fs from "fs";

const dataset = await rdf.dataset().import(rdf.fromFile('results/dwh_mapping/radar_oslo.ttl'))
const report = await validate(dataset);
fs.writeFileSync('results/dwh_mapping/shacl_report.ttl', report)
