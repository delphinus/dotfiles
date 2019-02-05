import { writeFile } from "fs"
import { promisify } from "util"
import { Content } from "./content"
import { tempFile } from "./temp-file"

const writeFileAsync = promisify(writeFile)

interface ReadCase {
    content: string
    result: string[]
    case: string
}

describe("Content", () => {
    describe("read", () => {
        const url = (name: string) =>
            `https://raw.github.com/hogehoge/${name}.gitignore`

        describe.each`
            content                                         | result                                                                                          | case
            ${"hogehogeo\nfugafugao"}                       | ${[]}                                                                                           | ${"no valid settings"}
            ${"### hoge\nfuga\nhoge"}                       | ${[{ setting: "### hoge\nfuga\nhoge" }]}                                                        | ${"a setting for one setting"}
            ${"### hoge\nfuga\nhoge\n### fuga\nhoge\nfuga"} | ${[{ setting: "### hoge\nfuga\nhoge\n" }, { setting: "### fuga\nhoge\nfuga" }]}                 | ${"settings for two setting"}
            ${`### ${url("Python")}\nhoge`}                 | ${[{ name: "Python", setting: `### ${url("Python")}\nhoge` }]}                                  | ${"settings for one language"}
            ${`### ${url("Python")}\nhoge\n### fuga\nfuga`} | ${[{ name: "Python", setting: `### ${url("Python")}\nhoge\n` }, { setting: "### fuga\nfuga" }]} | ${"settings for one language and one setting"}
        `("when content has $case", (arg: ReadCase) =>
            it("returns valid string array", async () => {
                const tmp = tempFile()
                await writeFileAsync(tmp, arg.content, { mode: 0o0600 })
                const content = new Content(tmp)
                await expect(content.read()).resolves.not.toThrow()
                expect(content.languages).toEqual(arg.result)
            }),
        )
    })

    describe("diffNames", () =>
        it("returns valid diff names", () => {
            const content = new Content("/dev/null")
            content.languages = [
                { name: "Python", setting: "fugahoge" },
                { setting: "hogefuga" },
                { name: "Go", setting: "hogefugao" },
            ]
            const result = content.diffNames([
                "fugahoge",
                "hogefugao",
                "fugahogeo",
            ])
            expect(result).toEqual(["Go"])
        }))
})
