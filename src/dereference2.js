// main.mjs
import fs from "fs";
import { parse } from "csv-parse/sync";
import { rdfDereferencer } from "rdf-dereference";
import { finished } from "stream/promises";
import { Writer } from "n3";

async function derefUrl(url) {
    let attemptUrl = url;
    let errorMsg = "";
    let quadCount = 0;
    let contentType = "";
    let turtle = "";

    for (let attempt = 0; attempt < 2; attempt++) {
        try {
            const { data, metadata, url: finalUrl } = await rdfDereferencer.dereference(attemptUrl);

            quadCount = 0;
            const writer = new Writer({ format: "Turtle" });

            data.on("data", quad => {
                quadCount++;
                writer.addQuad(quad);
            });

            await finished(data);

            turtle = await new Promise((resolve, reject) => {
                writer.end((err, result) => (err ? reject(err) : resolve(result)));
            });

            contentType = metadata?.contentType || "";
            attemptUrl = finalUrl;

            // Als contentType bruikbaar is, stoppen we hier
            if (contentType && contentType !== "text/xml") break;

            // Anders nog een poging met https://
            if (attempt === 0 && url.startsWith("http://")) {
                attemptUrl = url.replace(/^http:\/\//, "https://");
                console.log(`🔁 Opnieuw proberen met HTTPS: ${attemptUrl}`);
                continue;
            }

        } catch (err) {
            errorMsg = err.message || String(err);
        }
    }

    return { finalUrl: attemptUrl, turtle, quadCount, contentType, errorMsg };
}

async function main() {
    const csvContent = fs.readFileSync("source/conceptschemes2.csv", "utf8");
    const records = parse(csvContent, { columns: false, skip_empty_lines: true });
    const urls = records.map(row => row[0]);

    const logRows = [["url", "status", "contentType", "quadCount", "filename", "error"]];

    for (const [i, url] of urls.entries()) {
        console.log(`⏳ Dereferencen: ${url}`);
        const { finalUrl, turtle, quadCount, contentType, errorMsg } = await derefUrl(url);

        if (turtle && quadCount > 0) {
            const fileName = `results/dereference/output_${i + 1}.ttl`;
            fs.writeFileSync(fileName, turtle, "utf8");
            console.log(`📄 Geschreven: ${fileName} (${quadCount} quads)`);
            logRows.push([finalUrl, "ok", contentType, quadCount.toString(),  fileName, ""]);
        } else {
            console.error(`❌ Geen RDF-quads gevonden voor ${url}`);
            logRows.push([finalUrl, "error", contentType, quadCount.toString(), "",errorMsg]);
        }
    }

    const logCsv = logRows.map(r => r.join(",")).join("\n");
    fs.writeFileSync("results/dereference/log.csv", logCsv, "utf8");
    console.log("📝 Logbestand geschreven: log.csv");
}

//main();

const url = "https://data.vlaanderen.be/standaarden";
const res = await fetch(url, { redirect: "follow" });
const { data, metadata } = await rdfDereferencer.dereference(url);
console.log("Final URL:", res.url);
console.log("Content-Type:", res.headers.get("content-type"));
console.log("Content-Type:", metadata?.contentType);
console.log("metadata:", metadata);
console.log("constructor name:", data.constructor.name);
