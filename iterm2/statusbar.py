import iterm2


async def main(connection):
    # Define the configuration knobs:
    vl = "variable_length_demo"
    knobs = [iterm2.CheckboxKnob("Variable-Length Demo", False, vl)]
    component = iterm2.StatusBarComponent(
        short_description="Status Bar Demo",
        detailed_description="Tests script-provided status bar components",
        knobs=knobs,
        exemplar="row x cols",
        update_cadence=None,
        identifier="com.iterm2.example.status-bar-demo",
    )

    # This function gets called whenever any of the paths named in defaults (below) changes
    # or its configuration changes.
    # References specify paths to external variables (like rows) and binds them to
    # arguments to the registered function (coro). When any of those variables' values
    # change the function gets called.
    @iterm2.StatusBarRPC
    async def coro(
        knobs, rows=iterm2.Reference("rows"), cols=iterm2.Reference("columns")
    ):
        if vl in knobs and knobs[vl]:
            return [
                "This is an example of variable-length status bar components",
                "This is a demo of variable-length status bar components",
                "This demo status bar component has variable length",
                "Demonstrate variable-length status bar component",
                "Shows variable-length status bar component",
                "Shows variable-length text in status bar",
                "Variable-length text in status bar",
                "Variable-length text demo",
                "Var. length text demo",
                "It's getting tight",
            ]
        return "{}x{}".format(rows, cols)

    # Register the component.
    await component.async_register(connection, coro)


iterm2.run_forever(main)