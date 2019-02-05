import { Latest } from "./latest"

describe("Latest", () =>
    describe("read", () =>
        it("reads successfully from dump", async () => {
            const dumper = {
                async dump(name: string) {
                    return `${name}: hoge`
                },
            }
            const languages = [
                { name: "Python", setting: "hogefugao" },
                { setting: "fugahogeo" },
                { name: "Go", setting: "fugehogao" },
            ]
            const latest = new Latest("/dev/null", dumper)
            await expect(latest.read(languages)).resolves.not.toThrow()
            expect(latest.settings).toEqual([
                "Python: hoge",
                "fugahogeo",
                "Go: hoge",
            ])
        })))
