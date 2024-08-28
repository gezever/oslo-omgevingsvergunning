import rdf from '@zazuko/env-node'
import SHACLValidator from 'rdf-validate-shacl'

const shapes = await rdf.dataset().import(rdf.fromFile('main/resources/be/vlaanderen/data/id/applicatieprofiel/omgevingsvergunning/kandidaatstandaard/2024-06-20/shacl/omgevingsvergunning-ap-SHACL/omgevingsvergunning-ap-SHACL.ttl'))
async function validate(data) {
    console.log("Validation");
    const validator = new SHACLValidator(shapes, { factory: rdf })
    const report = await validator.validate(data)
    let paths = [];
    for (const result of report.results) {
        // See https://www.w3.org/TR/shacl/#results-validation-result for details
        // about each property
        // console.log(result.message)
        // console.log(result.path)
        // console.log(result.focusNode)
        // console.log(result.severity)
        // console.log(result.sourceConstraintComponent)
        // console.log(result.sourceShape)
        paths.push(result.path.value)
    }

    // Validation report as RDF dataset
    //console.log(await report.dataset.serialize({ format: 'text/n3' }))
    // Check conformance: `true` or `false`
    // console.log(report.conforms)
    //return report.conforms;
    const path = await Array.from(new Set(paths)).sort();
    const result = await report.dataset.serialize({ format: 'text/n3' })
    return  result
}
export default validate

