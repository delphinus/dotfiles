import { spawn } from "child_process"
import { writeFile } from "fs"
import { promisify } from "util"
import { Language } from "./content"

const spawnAsync = promisify(spawn)
const writeFileAsync = promisify(writeFile)

interface GiboLike {
    dump(name: string): Promise<string>
}

export class Latest {
    settings: string[] = []

    constructor(private filename: string, private gibo: GiboLike) {}

    async read(languages: Language[]) {
        this.settings = await Promise.all(
            languages.map(lang => {
                if (lang.name) {
                    return this.gibo.dump(lang.name)
                }
                return Promise.resolve(lang.setting)
            }),
        )
    }

    async showDiff(original: string) {
        await this.write()
        await spawnAsync(
            `git diff --color=always -u ${original} ${this.filename} | less`,
            [],
            {
                shell: true,
                stdio: "inherit",
            },
        )
    }

    async write(filename = this.filename) {
        await writeFileAsync(filename, this.settings.join(""), {
            encoding: "utf-8",
        })
    }
}
