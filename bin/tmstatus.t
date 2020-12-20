use 5.20.0;
use warnings;
use FindBin '$Bin';
use Test2::V0;
use Test::MockTime 'set_fixed_time';
use Time::Piece;

require "$Bin/tmstatus";

set_fixed_time(time);

subtest 'with_timestamp()' => sub {

    subtest 'when with valid Time::Piece object' => sub {
        my $timestamp = localtime->datetime;
        is with_timestamp('hogehoge') => "$timestamp\thogehoge",
            'returns with valid timestamp';
    };
};

subtest 'load()' => sub {

    subtest 'when with unexistent file' => sub {
        is load('/some/where/not/existent') => undef, 'returns undef';
    };

    subtest 'when with invalid file' => sub {
        # TODO: set more robust path
        like dies { load('/var/run/cron.pid') }, qr/Permission denied/,
            'dies with a valid exception';
    };
};

subtest 'safe_system()' => sub {

    subtest 'when with no exception' => sub {
        is safe_system('echo "hoge"') => 'hoge', 'returns stdout';
    };

    subtest 'when with any exception' => sub {
        # TODO: set more robust path
        like dies { safe_system('/tmp/__unknown_bin__') } =>
            qr/No such file or directory/,
            'dies with a valid error message';
    };
};

subtest 'parse()' => sub {

    is parse(<<EOF),
Backup session status:
{
    BackupPhase = Copying;
    ClientID = "com.apple.backupd";
    DateOfStateChange = "2020-12-14 00:32:41 +0000";
    DestinationID = "18E167B2-EA8C-4847-AD6A-84780BD58AB2";
    Progress =     {
        Percent = "3.812646833972822e-05";
        "_raw_Percent" = "3.812646833972822e-05";
        "_raw_totalBytes" = 647975044;
        bytes = 24705;
        files = 666;
        totalBytes = 647975044;
        totalFiles = 14613;
    };
    Running = 1;
    Stopping = 0;
}
EOF
        +{
            backupPhase => 'Copying',
            clientId => 'com.apple.backupd',
            dateOfStateChange => '2020-12-14 00:32:41 +0000',
            destinationId => '18E167B2-EA8C-4847-AD6A-84780BD58AB2',
            progress => +{
                percent => '3.812646833972822e-05',
                rawPercent => '3.812646833972822e-05',
                rawTotalBytes => 647975044,
                bytes => 24705,
                files => 666,
                totalBytes => 647975044,
                totalFiles => 14613,
            },
            running => 1,
            stopping => 0,
        }, 'returns a valid hash';
};

subtest 'commify()' => sub {

    subtest 'when with a positive integer' => sub {
        is commify(1234567) => '1,234,567', 'returns a valid string';
    };

    subtest 'when with a negative integer' => sub {
        is commify(-1234567) => '-1,234,567', 'returns a valid string';
    };

    subtest 'when with a positive decimal value' => sub {
        is commify(1234.5678) => '1,234.5678', 'returns a valid string';
    };

    subtest 'when with a negative decimal value' => sub {
        is commify(-1234.5678) => '-1,234.5678', 'returns a valid string';
    };
};

subtest 'get()' => sub {

    subtest 'when with a valid key' => sub {
        is get(+{hoge => 'fuga'}, 'hoge') => 'fuga', 'returns a valid value';
    };

    subtest 'when with a invalid key' => sub {

        subtest 'when with no default value' => sub {
            is get(+{hoge => 'fuga'}, 'hofu') => undef, 'returns an undef';
        };

        subtest 'when with the default value' => sub {
            is get(+{hoge => 'fuga'}, 'hofu', 1) => 1,
                'returns the default value';
        };
    };
};

subtest 'arrange()' => sub {

    is arrange(+{
    }), +{
    }, 'returns a valid hash';
};

done_testing;
