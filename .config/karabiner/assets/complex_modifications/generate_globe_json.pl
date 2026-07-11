#!/usr/bin/env perl
use utf8;
use 5.34.0;
use warnings;
use JSON::PP;

my @manipulators = map {
    my $key = $_;
    map {
        my @modifiers = !defined ? () :
            ref ? $_->@* :
            $_;
        {
            type => 'basic',
            from => {
                key_code => $key,
                (@modifiers ? (
                    modifiers => { mandatory => \@modifiers },
                ) : ()),
            },
            to => [{ key_code => $key, modifiers => ['fn', @modifiers]}],
            conditions => [{ type => 'variable_if', name => 'globe_key_mode', value => 1 }],
        }
    } undef, 'left_shift', 'left_control', ['left_shift', 'left_control'],
        ['left_shift', 'left_command'], ['left_control', 'left_command'],
        ['left_shift', 'left_control', 'left_command'];
} 'a' .. 'z', 'left_arrow', 'right_arrow', 'up_arrow', 'down_arrow';

my @custom_manipulators = map {
    {
        type => 'basic',
        from => {
            key_code => $_,
            modifiers => {
                mandatory => ['left_control', 'left_option'],
            },
        },
        to => [{ key_code => $_, modifiers => ['left_shift', 'left_control', 'left_command', 'left_option'] }],
        conditions => [{ type => 'variable_if', name => 'globe_key_mode', value => 1 }],
    }
} 'up_arrow', 'right_arrow', 'down_arrow', 'left_arrow';

my $json = {
    title => '[delphinus] 🌐 key',
    rules => [
        {
            description => '[delphinus] Change tab to 🌐 key. (Post tab if pressed alone)',
            manipulators => [
                {
                    from => { key_code => 'tab', modifiers => { mandatory => ['any'] } },
                    to => [{ set_variable => { name => 'globe_key_mode', value => 1 } }],
                    to_if_alone => [{ key_code => 'tab' }],
                    to_after_key_up => [{ set_variable => { name => 'globe_key_mode', value => 0 } }],
                    type => 'basic',
                },
            ],
        },
        {
            description => '[delphinus] 🌐 key mode',
            manipulators => [@manipulators, @custom_manipulators],
        },
        {
            description => '[delphinus] Overwrite 🌐 key rules',
            manipulators => [
                {
                    from => { key_code => 'tab', modifiers => { mandatory => ['left_shift'] } },
                    to => { key_code => 'tab', modifiers => ['shift'] },
                    type => 'basic',
                },
                {
                    from => { key_code => 'tab', modifiers => { mandatory => ['left_command'] } },
                    to => { key_code => 'tab', modifiers => ['command'] },
                    type => 'basic',
                },
                {
                    from => { key_code => 'tab', modifiers => { mandatory => ['left_shift', 'left_command'] } },
                    to => { key_code => 'tab', modifiers => ['shift', 'command'] },
                    type => 'basic',
                },
            ],
        },
    ],
};

# Parallels Desktop (VM ウィンドウ / Coherence ゲストアプリ) が前面のときは
# これらのショートカットを無効化する。全 manipulator の conditions に付与する。
my $parallels_cond = {
    type => 'frontmost_application_unless',
    bundle_identifiers => ['^com\.parallels\.desktop\.console$', '^com\.parallels\.winapp\.'],
};
for my $rule (@{$json->{rules}}) {
    for my $m (@{$rule->{manipulators}}) {
        push @{$m->{conditions}}, $parallels_cond;
    }
}

print JSON::PP->new->utf8(1)->indent(1)->space_after(1)->indent_length(2)->canonical(1)->encode($json);
