
// main.mjs
import fs from "fs";
import { parse } from "csv-parse/sync";
import { rdfDereferencer } from "rdf-dereference";
import { finished } from "stream/promises";
import { Writer } from "n3";

async function main() {
    const csvContent = fs.readFileSync("source/conceptschemes3.csv", "utf8");
    const urls = csvContent.split('\n')

    const logRows = [["url", "status", "contentType", "quadCount", "turtle"]];

    for (const [i, url] of urls.entries()) {
        try {
            console.log(`⏳ Dereferencen: ${url}`);
            const { data, metadata } = await rdfDereferencer.dereference(url);

            let quadCount = 0;
            const writer = new Writer({ format: "Turtle" });

            // Quads naar de writer toevoegen
            data.on("data", quad => {
                quadCount++;
                writer.addQuad(quad);
            });

            data.on("error", err => {
                console.error(`⚠️ Streamfout bij ${url}:`, err);
            });

            // Wachten tot RDF-stream klaar is
            await finished(data);

            // Pas hier writer afsluiten en opslaan
            const fileName = `results/dereference/output_${i + 1}.ttl`;
            const result = await new Promise((resolve, reject) => {
                writer.end((err, output) => (err ? reject(err) : resolve(output)));
            });
            fs.writeFileSync(fileName, result, "utf8");

            console.log(`📄 Geschreven: ${fileName} (${quadCount} quads)`);

            logRows.push([url, "ok", metadata?.contentType || "", quadCount.toString(), fileName]);
        } catch (err) {
            console.error(`❌ Fout bij ${url}:`, err);
            logRows.push([url, "error", "", "0", ""]);
        }
    }

    // Logfile opslaan
    const logCsv = logRows.map(r => r.join(",")).join("\n");
    fs.writeFileSync("results/dereference/log.csv", logCsv, "utf8");
    console.log("📝 Logbestand geschreven: log.csv");
}


main();

