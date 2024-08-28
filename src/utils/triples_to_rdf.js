

async function add_graph(rdf, graph) {
    var quads = []
    for (const triple of rdf.split(/\r?\n/)){
        //console.log(triple)
        var quad = triple.replace('>.', '> ' + graph + '.')
        if (triple != "") quads.push(quad)
     }
    return  quads.join('\n')
}
export default add_graph

