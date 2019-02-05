import { readFile } from "fs"
import { promisify } from "util"

const readFileAsync = promisify(readFile)

export interface Language {
    setting: string
    name?: string
}

export class Content {
    static re = /^### (.*)/gm
    static urlRe = new RegExp(
        String.raw`^https://raw\.github\.com/.*/(\w+)\.gitignore$`,
    )

    languages: Language[] = []

    constructor(private filename: string) {}

    async read() {
        const content = await readFileAsync(this.filename, {
            encoding: "utf-8",
        })

        interface Matched {
            index: number
            name?: string
        }

        const matched: Matched[] = []
        let m: RegExpExecArray | null
        /* tslint:disable:no-conditional-assignment */
        while ((m = Content.re.exec(content))) {
            /* tslint:enable:no-conditional-assignment */
            const result: Matched = {
                index: m.index,
            }
            const url = m[1]
            if (url && url.match(Content.urlRe)) {
                result.name = RegExp.$1
            }
            matched.push(result)
        }
        if (matched.length === 1) {
            this.languages = [{ setting: content, name: matched[0].name }]
            return
        }
        this.languages = matched.reduce<Language[]>((result, mm, i) => {
            const setting =
                i === matched.length - 1
                    ? content.slice(mm.index)
                    : content.slice(mm.index, matched[i + 1].index)
            result.push({ setting, name: mm.name })
            return result
        }, [])
    }

    diffNames(latest: string[]) {
        return this.languages.reduce<string[]>((result, lang, index) => {
            if (lang.name && lang.setting !== latest[index]) {
                result.push(lang.name)
            }
            return result
        }, [])
    }
}
