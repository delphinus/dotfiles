import { tmpdir } from "os"
import { basename, join } from "path"

export const tempFile = () =>
    join(
        tmpdir(),
        `${basename(__filename)}-${Math.floor(Math.random() * 100000000)}`,
    )
