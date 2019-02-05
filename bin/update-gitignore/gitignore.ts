import { copyFile } from "fs"
import { promisify } from "util"
import { Content } from "./content"
import { Gibo } from "./gibo"
import { Latest } from "./latest"
import { tempFile } from "./temp-file"

const copyFileAsync = promisify(copyFile)

export class GitIgnore {
    static async create(filename = "./.gitignore") {
        const gibo = await Gibo.create()
        return new GitIgnore(filename, gibo)
    }

    private content: Content
    private latest: Latest
    private backupFilename: string

    private constructor(private filename = "./.gitignore", private gibo: Gibo) {
        this.content = new Content(filename)
        this.latest = new Latest(tempFile(), gibo)
        this.backupFilename = tempFile()
    }

    async read() {
        await this.content.read()
        await this.latest.read(this.content.languages)
    }

    diffNames() {
        return this.content.diffNames(this.latest.settings)
    }

    async showDiff() {
        await this.latest.showDiff(this.filename)
    }

    async update() {
        await this.gibo.update()
    }

    async write() {
        await this.backup()
        try {
            await this.latest.write(this.filename)
        } catch (e) {
            await this.restore()
            throw e
        }
    }

    private async backup() {
        await copyFileAsync(this.filename, this.backupFilename)
    }

    private async restore() {
        await copyFileAsync(this.backupFilename, this.filename)
    }
}
