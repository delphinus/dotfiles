import { exec, spawn } from "child_process"
import { promisify } from "util"

const execAsync = promisify(exec)
const spawnAsync = promisify(spawn)

export class Gibo {
    static async create(exeName = "gibo") {
        try {
            const { stdout } = await execAsync(`which ${exeName}`)
            return new Gibo(stdout.trim())
        } catch (e) {
            throw new Error("executable: `gibo` not found")
        }
    }

    private constructor(public exe: string) {}

    async update() {
        await spawnAsync(this.exe, ["update"], { stdio: "inherit" })
    }

    async dump(name: string) {
        // `gibo dump` always return exit code: 0.  If it has stderr, it
        // has failed.
        const { stdout, stderr } = await execAsync(`${this.exe} dump ${name}`)
        if (stderr.length) {
            throw new Error(`failed to dump: ${name}`)
        }
        return stdout
    }
}
