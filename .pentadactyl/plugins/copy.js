var INFO =
['plugin', {
        name: 'copy',
        version: '0.8.0',
        href: 'http://svn.coderepos.org/share/lang/javascript/vimperator-plugins/trunk/copy.js',
        summary: 'copy strings from the template (like CopyURL+)',
        xmlns: 'http://vimperator.org/namespaces/dactyl',
    },
    ['author', {email: 'teramako@gmail.com'}, 'teramako'],
    ['license', 'MPL 1.1/GPL 2.0/LGPL 2.1'],
    ['project', {name: 'Vimperator', 'min-version': '2.3'}],
    ['item', {},
        ['tags', {}, ':copy'],
        ['spec', {}, ':copy <a>label</a>'],
        ['description', {},
            ['p', {}, 'copy the argument replaced some certain string.']]],
    ['item', {},
        ['tags', {}, ':copy!'],
        ['spec', {}, ':copy! <a>expr</a>'],
        ['description', {},
            ['p', {}, 'evaluate the argument(javascript code) and copythe result.']]],
    ['item', {},
        ['tags', {}, 'copy-keyword'],
        ['spec', {}, 'copy-keyword'],
        ['description', {},
            ['p', {}, 'replaces following keywords'],
            ['dl', {},
                ['dt', {}, '%TITLE%'],
                ['dd', {}, 'to the title of the current page'],
                ['dt', {}, '%URL%'],
                ['dd', {}, 'to the currenet URL'],
                ['dt', {}, '%SEL'],
                ['dd', {}, 'to the string of selection'],
                ['dt', {}, '%HTMLSEL'],
                ['dd', {}, 'to the html string of selection'],
                ['dt', {}, '%HOSTNAME%'],
                ['dd', {}, 'to the hostname of the current location'],
                ['dt', {}, '%PATHNAME%'],
                ['dd', {}, 'to the pathname of the current location'],
                ['dt', {}, '%HOST%'],
                ['dd', {}, 'to the host of the current location'],
                ['dt', {}, '%PORT%'],
                ['dd', {}, 'to the port of the current location'],
                ['dt', {}, '%PROTOCOL%'],
                ['dd', {}, 'to the protocol of the current location'],
                ['dt', {}, '%SERCH%'],
                ['dd', {}, 'to the search(?...) of the curernt location'],
                ['dt', {}, '%HASH%'],
                ['dd', {}, 'to the hash(anchor #..) of the current location']]]],
    ['item', {},
        ['tags', {}, 'copy-template'],
        ['spec', {}, 'copy-template'],
        ['description', {},
            ['p', {}, 'you can set your own template using inline JavaScript'],
            ['code', {},
                'javascript <<EOM' +
                'dactyl.globalVariables.copy_templates = [' +
                '  { label: \'titleAndURL\',    value: \'%TITLE%\n%URL%\' },' +
                '  { label: \'title\',          value: \'%TITLE%\', map: \',y\' },' +
                '  { label: \'anchor\',         value: \'<a href="%URL%">%TITLE%</a>\' },' +
                '  { label: \'selanchor\',      value: \'<a href="%URL%" title="%TITLE%">%SEL%</a>\' },' +
                '  { label: \'htmlblockquote\', value: \'<blockquote cite="%URL%" title="%TITLE%">%HTMLSEL%</blockquote>\' }' +
                '  { label: \'ASIN\',   value: \'copy ASIN code from Amazon\', custom: function(){return content.document.getElementById(\'ASIN\').value;} },' +
                '];' +
                'EOM'],
            ['dl', {},
                ['dt', {}, 'label'],
                ['dd', {}, 'template name which is command argument'],
                ['dt', {}, 'value'],
                ['dd', {}, 'copy string. ', ['a', {}, 'copy-keyword'], ' is replaced'],
                ['dt', {}, 'map'],
                ['dd', {}, 'key map ', ['a', {}, 'lhs'], ' (optional)'],
                ['dt', {}, 'custom'],
                ['dd', {},
                    ['p', {}, ['a', {}, 'function'], ' or ', ['a', {}, 'Array'], ' (optional)'],
                    ['dl', {},
                        ['dt', {}, ['a', {}, 'function']],
                        ['dd', {}, 'execute the function and copy return value, if specified'],
                        ['dt', {}, ['a', {}, 'Array']],
                        ['dd', {},
                            'replace to the ', ['a', {}, 'value'],
                            ' by normal way at first. then replace words matched ',
                            ['a', {}, 'Array'], '[0] in the repalced string to ', ['a', {}, 'Array'], '[1]. ',
                            ['dl', {},
                            ['dt', {}, ['a', {}, 'Array'], '[0]'],
                            ['dd', {}, 'String or RegExp'],
                            ['dt', {}, ['a', {}, 'Array'], '[1]'],
                            ['dd', {}, 'String or Function']],
                            'see: ',
                            ['link', {topic: 'http://developer.mozilla.org/en/docs/Core_JavaScript_1.5_Reference:Global_Objects:String:replace'},
                                'http://developer.mozilla.org/en/docs/Core_JavaScript_1.5_Reference:Global_Objects:String:replace']]]]]]],
    ['item', {},
        ['tags', {}, 'copy-option'],
        ['spec', {}, 'copy-option'],
        ['description', {},
            ['code', {}, ['ex', {}, 'dactyl.globalVariables.copy_use_wedata = false; // false by default']],
            ['p', {}, 'true に設定すると wedata からテンプレートを読込みます。'],
            ['code', {}, ['ex', {}, 'dactyl.globalVariables.copy_wedata_include_custom = true; // false by default']],
            ['p', {},
                'custom が設定された wedata を読込みます。 ' +
                'SandBox でなく、window.eval を利用してオブジェクトする為、 ' +
                'セキュリティ上の理由で初期設定は false になっています。 ' +
                'true に設定する場合は、動作を理解したうえ自己責任でご利用ください。'],
            ['code', {}, ['ex', {}, 'dactyl.globalVariables.copy_wedata_exclude_labels = [\'pathtraqnormalize\', ];']],
            ['p', {}, 'wedata から読込まない label のリストを定義します。']]],
];

var PLUGIN_INFO =
['VimperatorPlugin', {},
    ['name', {}, '{NAME}'],
    ['description', {}, 'enable to copy strings from a template (like CopyURL+)'],
    ['description', {lang: 'ja'}, 'テンプレートから文字列のコピーを可能にします（CopyURL+みたいなもの）'],
    ['minVersion', {}, '2.0pre'],
    ['maxVersion', {}, '2.0pre'],
    ['updateURL', {}, 'http://svn.coderepos.org/share/lang/javascript/vimperator-plugins/trunk/copy.js'],
    ['author', {mail: 'teramako@gmail.com', homepage: 'http://vimperator.g.hatena.ne.jp/teramako/'}, 'teramako'],
    ['license', {}, 'MPL 1.1/GPL 2.0/LGPL 2.1'],
    ['version', {}, '0.7.5']];

dactyl.plugins.exCopy = (function(){
var excludeLabelsMap = {};
var copy_templates = [];
if (!dactyl.globalVariables.copy_templates){
    dactyl.globalVariables.copy_templates = [
        { label: 'titleAndURL',    value: '%TITLE%\n%URL%' },
        { label: 'title',          value: '%TITLE%' },
        { label: 'anchor',         value: '<a href="%URL%">%TITLE%</a>' },
        { label: 'selanchor',      value: '<a href="%URL%" title="%TITLE%">%SEL%</a>' },
        { label: 'htmlblockquote', value: '<blockquote cite="%URL%" title="%TITLE%">%HTMLSEL%</blockquote>' }
    ];
}

copy_templates = dactyl.globalVariables.copy_templates.map(function(t){
    return { label: t.label, value: t.value, custom: t.custom, map: t.map }
});

copy_templates.forEach(function(template){
    if (typeof template.map == 'string')
        addUserMap(template.label, [template.map]);
    else if (template.map instanceof Array)
        addUserMap(template.label, template.map);
});

const REPLACE_TABLE = {
    get TITLE () buffer.title,
    get URL () buffer.URL,
    get SEL () {
        var sel = '';
        var win = new XPCNativeWrapper(window.content.window);
        var selection =  win.getSelection();
        if (selection.rangeCount < 1)
            return '';

        for (var i=0, c=selection.rangeCount; i<c; i++){
            sel += selection.getRangeAt(i).toString();
        }
        return sel;
    },
    get HTMLSEL () {
        var htmlsel = '';
        var win = new XPCNativeWrapper(window.content.window);
        var selection =  win.getSelection();
        if (selection.rangeCount < 1)
            return '';

        var serializer = new XMLSerializer();
        for (var i=0, c=selection.rangeCount; i<c; i++){
            htmlsel += serializer.serializeToString(selection.getRangeAt(i).cloneContents());
        }
        return htmlsel.replace(/<(\/)?(\w+)([\s\S]*?)>/g, function(all, close, tag, attr){
            return "<" + close + tag.toLowerCase() + attr + ">";
        });
    },
    get CLIP () {
        return util.readFromClipboard();
    }
};
'hostname pathname host port protocol search hash'.split(' ').forEach(function (name){
    REPLACE_TABLE[name.toUpperCase()] = function () content.location && content.location[name];
});

// used when argument is none
//const defaultValue = templates[0].label;
commands.addUserCommand(['copy'],'Copy to clipboard',
    function(args){
        dactyl.plugins.exCopy.copy(args.literalArg, args.bang, !!args["-append"]);
    },{
        completer: function(context, args){
            if (args.bang){
                completion.javascript(context);
                return;
            }
            context.title = ['Template','Value'];
            var templates = copy_templates.map(function(template)
                [template.label, dactyl.modules.util.escapeString(template.value, '"')]
            );
            if (!context.filter){ context.completions = templates; return; }
            var candidates = [];
            var filter = context.filter.toLowerCase();
            context.completions = templates.filter(function(template) template[0].toLowerCase().indexOf(filter) == 0);
        },
        literal: 0,
        bang: true,
        options: [
            [["-append","-a"], commands.OPTION_NOARG]
        ]
    },
    true
);

function addUserMap(label, map){
    mappings.addUserMap([modes.NORMAL,modes.VISUAL], map,
        label,
        function(){ dactyl.plugins.exCopy.copy(label); },
        { rhs: label }
    );
}
function getCopyTemplate(label){
    var ret = null;
    copy_templates.some(function(template)
        template.label == label ? (ret = template) && true : false);
    return ret;
}
function replaceVariable(str){
    if (!str) return '';
    function replacer(orig, name){ //{{{
        if (name == '')
            return '%';
        if (!REPLACE_TABLE.hasOwnProperty(name))
            return orig;
        let value = REPLACE_TABLE[name];
        if (typeof value == 'function')
            return value();
        else
            return value.toString();
        return orig;
    } //}}}
    return str.replace(/%([A-Z]*)%/g, replacer);
}

function wedataRegister(item){
    var libly = dactyl.plugins.libly;
    var logger = libly.$U.getLogger("copy");
    item = item.data;
    if (excludeLabelsMap[item.label]) return;

    if (item.custom && item.custom.toLowerCase().indexOf('function') != -1) {
        if (!dactyl.globalVariables.copy_wedata_include_custom ||
             item.label == 'test') {
            logger.log('skip: ' + item.label);
            return;
        }

        let custom = (function(item){

            return function(value, value2){
                var STORE_KEY = 'plugins-copy-ok-func';
                var store = storage.newMap(STORE_KEY, true);
                var check = store.get(item.label);
                var ans;

                if (!check){
                    ans = window.confirm(
                        'warning!!!: execute "' + item.label + '" ok ?\n' +
                        '(this function is working with unsafe sandbox.)\n\n' +
                        '----- execute code -----\n\n' +
                        'value: ' + item.value + '\n' +
                        'function: ' +
                        item.custom
                    );
                } else {
                    if (item.value == check.value &&
                        item.custom == check.custom &&
                        item.map == check.map){
                        ans = true;
                    } else {
                        ans = window.confirm(
                            'warning!!!: "' + item.label + '" was changed when you registered the function.\n' +
                            '(this function is working with unsafe sandbox.)\n\n' +
                            '----- execute code -----\n\n' +
                            'value: ' + item.value + '\n' +
                            'function: ' +
                            item.custom
                        );
                    }
                }

                if (!ans) return;
                store.set(item.label, item);
                store.save();

                var func;
                try{
                    func = window.eval('(' + item.custom + ')');
                } catch (e){
                    logger.echoerr(e);
                    logger.log(item.custom);
                    return;
                }
                return func(value, value2);
            };
        })(item);

        exCopyManager.add(item.label, item.value, custom, item.map);
    } else {
        exCopyManager.add(item.label, item.value, null, item.map);
    }
}
var exCopyManager = {
    add: function(label, value, custom, map){
        var template = {label: label, value: value, custom: custom, map: map};
        copy_templates.unshift(template);
        if (map) addUserMap(label, map);

        return template;
    },
    get: function(label){
        return getCopyTemplate(label);
    },
    copy: function(arg, special, appendMode){
        var copyString = '';
        var isError = false;
        if (special && arg){
            try {
                copyString = dactyl.eval(arg);
                switch (typeof copyString){
                    case 'object':
                        copyString = copyString === null ? 'null' : copyString.toSource();
                        break;
                    case 'function':
                        copyString = copyString.toString();
                        break;
                    case 'number':
                    case 'boolean':
                        copyString = '' + copyString;
                        break;
                    case 'undefined':
                        copyString = 'undefined';
                        break;
                }
            } catch (e){
                isError = true;
                copyString = e.toString();
            }
        } else {
            if (!arg) arg = copy_templates[0].label;

            var template = getCopyTemplate(arg) || {value: arg};
            if (typeof template.custom == 'function'){
                copyString = template.custom.call(this, template.value, replaceVariable(template.value));
            } else if (template.custom instanceof Array){
                copyString = replaceVariable(template.value).replace(template.custom[0], template.custom[1]);
            } else {
                copyString = replaceVariable(template.value);
            }
        }

        if (appendMode){
            copyString = util.readFromClipboard() + copyString;
        }

        if (copyString)
            dactyl.clipboardWrite(copyString);
        if (isError){
            dactyl.echoerr('CopiedErrorString: `' + copyString + "'");
        } else {
            dactyl.echo('CopiedString: `' + util.escapeHTML(copyString || '') + "'");
        }
    }
};

if (dactyl.globalVariables.copy_use_wedata){
    function loadWedata(){
        if (!dactyl.plugins.libly){
            dactyl.echomsg("need a _libly.js when use wedata.");
            return;
        }

        var libly = dactyl.plugins.libly;
        copy_templates.forEach(function(item) excludeLabelsMap[item.label] = item.value);
        if (dactyl.globalVariables.copy_wedata_exclude_labels)
            dactyl.globalVariables.copy_wedata_exclude_labels.forEach(function(item) excludeLabelsMap[item] = 1);
        var wedata = new libly.Wedata("vimp%20copy");
        wedata.getItems(24 * 60 * 60 * 1000, wedataRegister);
    }
    loadWedata();
}

return exCopyManager;
})();

// vim: set fdm=marker sw=4 ts=4 et:

