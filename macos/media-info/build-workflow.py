#!/usr/bin/python3 -I
# media-info.py を埋め込んだ Automator のクイックアクションを ~/Library/Services に作る。
# Ansible から毎回呼ばれるので、中身が変わったときだけ書き込み、標準出力に changed / unchanged を出す
import os
import plistlib
import sys
import uuid

NAME = "メディア情報"
# Automator はシェルに選んだファイルを引数で渡し、スクリプトは標準入力から流す。
# python3 を直接シェルにすると 1 つめのファイルをスクリプトとして読んでしまうので、bash から渡す
script = "exec /usr/bin/python3 -I - \"$@\" <<'PY'\n" + open(sys.argv[1], encoding="utf-8").read() + "PY\n"
dest = os.path.expanduser(f"~/Library/Services/{NAME}.workflow/Contents")
os.makedirs(dest, exist_ok=True)

info = {
    "CFBundleName": NAME,
    "NSServices": [
        {
            "NSBackgroundColorName": "background",
            "NSIconName": "NSInfo",
            "NSMenuItem": {"default": NAME},
            "NSMessage": "runWorkflowAsService",
            "NSRequiredContext": {"NSApplicationIdentifier": "com.apple.finder"},
            "NSSendFileTypes": ["public.audiovisual-content"],
        }
    ],
}

# 実行のたびに中身が変わらないよう、UUID は名前から決まるものにする
u = lambda key: str(uuid.uuid5(uuid.NAMESPACE_URL, f"media-info/{key}")).upper()
action = {
    "AMAccepts": {"Container": "List", "Optional": True, "Types": ["com.apple.cocoa.string"]},
    "AMActionVersion": "2.0.3",
    "AMApplication": ["Automator"],
    "AMParameterProperties": {
        "COMMAND_STRING": {},
        "CheckedForUserDefaultShell": {},
        "inputMethod": {},
        "shell": {},
        "source": {},
    },
    "AMProvides": {"Container": "List", "Types": ["com.apple.cocoa.string"]},
    "ActionBundlePath": "/System/Library/Automator/Run Shell Script.action",
    "ActionName": "シェルスクリプトを実行",
    "ActionParameters": {
        "COMMAND_STRING": script,
        "CheckedForUserDefaultShell": True,
        "inputMethod": 1,  # 引数として渡す
        "shell": "/bin/bash",
        "source": "",
    },
    "BundleIdentifier": "com.apple.RunShellScript",
    "CFBundleVersion": "2.0.3",
    "CanShowSelectedItemsWhenRun": False,
    "CanShowWhenRun": True,
    "Category": ["AMCategoryUtilities"],
    "Class Name": "RunShellScriptAction",
    "InputUUID": u("input"),
    "Keywords": ["Shell", "Script", "Command", "Run", "Unix"],
    "OutputUUID": u("output"),
    "UUID": u("action"),
    "UnlocalizedApplications": ["Automator"],
    "isViewVisible": 1,
}

document = {
    "AMApplicationBuild": "528",
    "AMApplicationVersion": "2.10",
    "AMDocumentVersion": "2",
    "actions": [{"action": action, "isViewVisible": 1}],
    "connectors": {},
    "workflowMetaData": {
        "applicationBundleID": "com.apple.finder",
        "applicationBundleIDsByPath": {"/System/Library/CoreServices/Finder.app": "com.apple.finder"},
        "applicationPath": "/System/Library/CoreServices/Finder.app",
        "applicationPaths": ["/System/Library/CoreServices/Finder.app"],
        "inputTypeIdentifier": "com.apple.Automator.fileSystemObject",
        "outputTypeIdentifier": "com.apple.Automator.nothing",
        "presentationMode": 15,
        "processesInput": False,
        "serviceApplicationBundleID": "com.apple.finder",
        "serviceApplicationPath": "/System/Library/CoreServices/Finder.app",
        "serviceInputTypeIdentifier": "com.apple.Automator.fileSystemObject",
        "serviceOutputTypeIdentifier": "com.apple.Automator.nothing",
        "serviceProcessesInput": False,
        "systemImageName": "NSActionTemplate",
        "useAutomaticInputType": False,
        "workflowTypeIdentifier": "com.apple.Automator.servicesMenu",
    },
}

changed = False
for name, data in [("Info.plist", info), ("document.wflow", document)]:
    path = f"{dest}/{name}"
    new = plistlib.dumps(data)
    try:
        with open(path, "rb") as fp:
            if fp.read() == new:
                continue
    except FileNotFoundError:
        pass
    with open(path, "wb") as fp:
        fp.write(new)
    changed = True
print("changed" if changed else "unchanged")
