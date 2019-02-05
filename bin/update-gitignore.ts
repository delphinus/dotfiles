#!/usr/bin/env npx ts-node
import meow from "meow"
import { relative } from "path"
import prompts from "prompts"
import { GitIgnore } from "./update-gitignore/gitignore"

const thisFile = relative(".", __filename)

const cli = meow({
    description: "Updater for .gitignore",
    flags: {
        filename: {
            alias: "f",
            default: "./.gitignore",
            type: "string",
        },
        "show-diff": {
            alias: "d",
            default: false,
            type: "boolean",
        },
        update: {
            alias: "u",
            default: false,
            type: "boolean",
        },
        yes: {
            alias: "y",
            default: false,
            type: "boolean",
        },
    },
    help: `
        Usage
          $ ${thisFile}

        Options
          --filename, -f   The target filename.  default: './.gitignore'
          --show-diff, -d  Show diffs from the latest .gitignore. default: false
          --update, -u     Update gibo.  default: false
          --yes, -y        If set, it does not confirm before writing.  default: false
          --help           Show this message.  default: false
    `,
})
;(async () => {
    const confirm = () =>
        prompts({
            initial: false,
            message: "Proceed?",
            name: "proceed",
            type: "confirm",
        }).then(result => !!result.proceed)
    try {
        const gitignore = await GitIgnore.create(cli.flags.filename)
        if (!!cli.flags.update) {
            console.log("updating gibo...")
            await gitignore.update()
        }
        await gitignore.read()
        const diffNames = gitignore.diffNames()
        if (diffNames.length === 0) {
            console.log("no updates found")
            return
        }
        console.log(`updates found: ${diffNames.join(", ")}`)
        if (!!cli.flags.showDiff) {
            console.log("launching diff command...")
            await gitignore.showDiff()
            return
        }
        if (!!cli.flags.yes || (await confirm())) {
            console.log("writing the latest .gitignore...")
            await gitignore.write()
        }
    } catch (e) {
        console.error(e)
        process.exit(1)
    }
})()
