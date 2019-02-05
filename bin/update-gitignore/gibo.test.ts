import { Gibo } from "./gibo"

describe("Gibo", () => {
    describe("create", () => {
        describe("when the executable exists", () =>
            it("returns a valid path", async () => {
                let gibo: Gibo
                await expect(
                    (async () => (gibo = await Gibo.create("sh")))(),
                ).resolves.not.toThrow()
                expect(gibo!.exe).toBe("/bin/sh")
            }))

        describe("when the executable does not exist", () =>
            it("throws an exception", async () => {
                await expect(
                    Gibo.create("this_might_not_exist"),
                ).rejects.toThrowError("executable: `gibo` not found")
            }))
    })

    describe("dump", () => {
        describe("when valid name supplied", () =>
            it("returns a result safely", async () => {
                let gibo: Gibo
                await expect(
                    (async () => (gibo = await Gibo.create()))(),
                ).resolves.not.toThrow()
                await expect(gibo!.dump("Node")).resolves.not.toThrow()
            }))

        describe("when invalid name supplied", () =>
            it("throws an exception", async () => {
                const name = "This_might_not_exist"
                let gibo: Gibo
                await expect(
                    (async () => (gibo = await Gibo.create()))(),
                ).resolves.not.toThrow()
                await expect(gibo!.dump(name)).rejects.toThrowError(
                    `failed to dump: ${name}`,
                )
            }))
    })
})
