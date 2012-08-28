use utf8;
use strict;
use lib '../ext/File-Glob/blib/lib';
use lib '../ext/File-Glob/blib/arch';
use lib '../lib';
require './../t/test.pl';

use Cwd;
use Data::Dumper;
use Encode;
use Win32;

local $Data::Dumper::Sortkeys=1;

my $script_dir = do {
    __FILE__ =~ m/^(.*)\\/ or die;
    $1;
};

#chdir, chmod, chown, chroot, exec, link, lstat, mkdir, rename, rmdir, stat, symlink, truncate, unlink, utime, -X
#%ENV
#glob (aka the <*>)
#open, opendir, sysopen
#qx (aka the backtick operator), system
#readdir, readlink

prepare: {
    my @dirs = map { "$script_dir\\using_wide\\$_" } (
        'dir_en_latin',
        'dir_ja_日本語',
        'dir_ja_日本語♥',
    );
    my @files = map {
        my $fn = $_;
        ("$script_dir\\using_wide\\$fn", map { "$_\\$fn" } @dirs);
    } (
        'file_en_latin.txt',
        'file_ja_日本語.txt',
        'file_ja_日本語♥.txt',
        'echo_self_en_latin.bat',
        'echo_self_ja_日本語.bat',
        'echo_self_ja_日本語♥.bat',
    );
    my @bat_files = grep { m/\.bat$/i } @files;

    for my $dir (@dirs) {
        Win32::CreateDirectory($dir);
    }
    for my $file (@files) {
        Win32::CreateFile($file);
    }
    for my $bat_file (@bat_files) {
        my $short = Win32::GetShortPathName($bat_file);
        open(my $fh, ">", $short) or die;
        print $fh q(echo %~nx0);
    }
    for my $file (@files) {
        utime(1,1,$file);
    }
}

chdir: {
    my $cwd = Cwd::getcwd();

    my $en_dir = "$script_dir\\using_wide\\dir_en_latin";
    my $ja_dir = "$script_dir\\using_wide\\dir_ja_日本語";
    utf8::upgrade($en_dir);
    utf8::upgrade($ja_dir);
    ok( utf8::is_utf8($en_dir) );
    ok( utf8::is_utf8($ja_dir) );

    #before: {
    #    # encoded latin1/codepage
    #    ok(  chdir(encode("latin1",$en_dir)) );
    #    ok(  chdir($cwd), "cwd" );
    #    ok(  chdir(encode("cp932", $ja_dir)) );
    #    ok(  chdir($cwd), "cwd" );
    #
    #    # decoded
    #    ok(  chdir($en_dir) );
    #    ok(  chdir($cwd), "cwd" );
    #    ok( !chdir($ja_dir) );
    #    ok(  chdir($cwd), "cwd" );
    #
    #    # encoded utf8
    #    ok(  chdir( encode("utf8", $en_dir)) );
    #    ok(  chdir($cwd), "cwd" );
    #    ok( !chdir( encode("utf8", $ja_dir)) );
    #    ok(  chdir($cwd), "cwd" );
    #}

    if (${^TAINT}) {
        eval { chdir($cwd) };
        ok( $@, "Insecure dependency in chdir while running with -T switch" );
    } else {
        # encoded latin1/codepage
        ok(  chdir(encode("latin1",$en_dir)) );
        ok(  chdir($cwd), "cwd" );
        ok(  chdir(encode("cp932", $ja_dir)) );
        ok(  chdir($cwd), "cwd" );

        # decoded
        ok(  chdir($en_dir) );
        ok(  chdir($cwd), "cwd" );
        ok(  chdir($ja_dir) );
        ok(  chdir($cwd), "cwd" );

        # encoded utf8
        ok(  chdir( encode("utf8",  $en_dir)) );
        ok(  chdir($cwd), "cwd" );
        ok(  chdir( encode("cp932", $en_dir)) );
        ok(  chdir($cwd), "cwd" );
        ok(  chdir( encode("utf8",  $ja_dir)) );
        ok(  chdir($cwd), "cwd" );
        ok(  chdir( encode("cp932", $ja_dir)) );
        ok(  chdir($cwd), "cwd" );
    }
}

chmod: {
    my $en_file = "$script_dir\\using_wide\\file_en_latin.txt";
    my $ja_file = "$script_dir\\using_wide\\file_ja_日本語.txt";
    my $u8_file = "$script_dir\\using_wide\\file_ja_日本語♥.txt";
    utf8::upgrade($en_file);
    utf8::upgrade($ja_file);
    utf8::upgrade($u8_file);
    ok( utf8::is_utf8($en_file) );
    ok( utf8::is_utf8($ja_file) );
    ok( utf8::is_utf8($u8_file) );

    #before: {
    #    # encoded latin1/codepage
    #    ok(  chmod "755", encode("latin1", $en_file) );
    #    ok(  chmod "755", encode("cp932",  $ja_file) );
    #    ok( !chmod "755", encode("utf8",   $u8_file) );
    #
    #    # decoded
    #    ok(  chmod "755", $en_file );
    #    ok( !chmod "755", $ja_file );
    #    ok( !chmod "755", $u8_file );
    #
    #    # encoded utf8
    #    ok(  chmod "755", encode("utf8", $en_file) );
    #    ok( !chmod "755", encode("utf8", $ja_file) );
    #    ok( !chmod "755", encode("utf8", $u8_file) );
    #}

    after: {
        # encoded latin1/codepage
        ok(  chmod "755", encode("latin1", $en_file) );
        ok(  chmod "755", encode("cp932",  $ja_file) );
        ok(  chmod "755", encode("utf8",   $u8_file) );

        # decoded
        ok(  chmod "755", $en_file );
        ok(  chmod "755", $ja_file );
        ok(  chmod "755", $u8_file );

        # encoded utf8
        ok(  chmod "755", encode("utf8", $en_file) );
        ok(  chmod "755", encode("utf8", $ja_file) );
        ok(  chmod "755", encode("utf8", $u8_file) );
    }
}

chroot: {
    # noop
    1;
}

exec: {
    my $en_bat = "$script_dir\\using_wide\\echo_self_en_latin.bat";
    my $ja_bat = "$script_dir\\using_wide\\echo_self_ja_日本語.bat";
    my $u8_bat = "$script_dir\\using_wide\\echo_self_ja_日本語♥.bat";
    utf8::upgrade($en_bat);
    utf8::upgrade($ja_bat);
    utf8::upgrade($u8_bat);
    ok( utf8::is_utf8($en_bat) );
    ok( utf8::is_utf8($ja_bat) );
    ok( utf8::is_utf8($u8_bat) );

    my $exec = sub {
        my $bat = shift;
        if (my $kid = fork) {
            wait;
            return $? == 0;
        }
        else {
            exec($bat);
        }
    };

    #before: {
    #    ok(  $exec->($en_bat) );
    #    ok( !$exec->($ja_bat) );
    #    ok( !$exec->($u8_bat) );
    #}

    after: {
        ok(  $exec->($en_bat) );
        ok(  $exec->($ja_bat) );
        ok(  $exec->($u8_bat) );
    }

    # win32.c win32_spawnvp() 以下をワイド化すること。
}

link: {
    my $en_file = "$script_dir\\using_wide\\file_en_latin.txt";
    my $ja_file = "$script_dir\\using_wide\\file_ja_日本語.txt";
    my $u8_file = "$script_dir\\using_wide\\file_ja_日本語♥.txt";
    utf8::upgrade($en_file);
    utf8::upgrade($ja_file);
    utf8::upgrade($u8_file);
    ok( utf8::is_utf8($en_file) );
    ok( utf8::is_utf8($ja_file) );
    ok( utf8::is_utf8($u8_file) );

    my $link = sub {
        my ($enc, $file) = @_;
        my $src = $file;
        #my $dst = "${file}_link";
        my $dst = tempfile();
        if ($enc) {
            $src = encode($enc, $src);
            #$dst = encode($enc, $dst);
        }
        link($src,$dst);
    };

    #before: {
    #    # encoded latin1/codepage
    #    ok(  $link->("latin1", $en_file) );
    #    ok(  $link->("cp932",  $ja_file) );
    #    ok( !$link->("utf8",   $u8_file) );
    #
    #    # decoded
    #    ok(  $link->(undef, $en_file) );
    #    ok( !$link->(undef, $ja_file) );
    #    ok( !$link->(undef, $u8_file) );
    #
    #    # encoded utf8
    #    ok(  $link->("utf8", $en_file) );
    #    ok( !$link->("utf8", $ja_file) );
    #    ok( !$link->("utf8", $u8_file) );
    #}

    after: {
        # encoded latin1/codepage
        ok(  $link->("latin1", $en_file) ) or warn $!;
        ok(  $link->("cp932",  $ja_file) );
        ok(  $link->("utf8",   $u8_file) );
    
        # decoded
        ok(  $link->(undef, $en_file) );
        ok(  $link->(undef, $ja_file) );
        ok(  $link->(undef, $u8_file) );
    
        # encoded utf8
        ok(  $link->("utf8", $en_file) );
        ok(  $link->("utf8", $ja_file) );
        ok(  $link->("utf8", $u8_file) );
    }
}

lstat_and_stat: {
    my $en_file = "$script_dir\\using_wide\\file_en_latin.txt";
    my $ja_file = "$script_dir\\using_wide\\file_ja_日本語.txt";
    my $u8_file = "$script_dir\\using_wide\\file_ja_日本語♥.txt";
    utf8::upgrade($en_file);
    utf8::upgrade($ja_file);
    utf8::upgrade($u8_file);
    ok( utf8::is_utf8($en_file) );
    ok( utf8::is_utf8($ja_file) );
    ok( utf8::is_utf8($u8_file) );

    my $lstat = sub {
        my ($enc, $file) = @_;
        if ($enc) {
            $file = encode($enc, $file);
        }
        my $ok_lstat = do {
            my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
                $atime,$mtime,$ctime,$blksize,$blocks)
                = lstat($file);
            $mtime;
        };
        my $ok_stat = do {
            my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
                $atime,$mtime,$ctime,$blksize,$blocks)
                = stat($file);
            $mtime;
        };
        $ok_lstat and $ok_stat;
    };

    #before: {
    #    # encoded latin1/codepage
    #    ok(  $lstat->("latin1", $en_file) );
    #    ok(  $lstat->("cp932",  $ja_file) );
    #    ok( !$lstat->("utf8",   $u8_file) );
    #
    #    # decoded
    #    ok(  $lstat->(undef, $en_file) );
    #    ok( !$lstat->(undef, $ja_file) );
    #    ok( !$lstat->(undef, $u8_file) );
    #
    #    # encoded utf8
    #    ok(  $lstat->("utf8", $en_file) );
    #    ok( !$lstat->("utf8", $ja_file) );
    #    ok( !$lstat->("utf8", $u8_file) );
    #}

    after: {
        # encoded latin1/codepage
        ok(  $lstat->("latin1", $en_file) );
        ok(  $lstat->("cp932",  $ja_file) );
        ok(  $lstat->("utf8",   $u8_file) );
    
        # decoded
        ok(  $lstat->(undef, $en_file) );
        ok(  $lstat->(undef, $ja_file) );
        ok(  $lstat->(undef, $u8_file) );
    
        # encoded utf8
        ok(  $lstat->("utf8", $en_file) );
        ok(  $lstat->("utf8", $ja_file) );
        ok(  $lstat->("utf8", $u8_file) );
    }
}

mkdir_and_rmdir: {
    my $en_dir = "$script_dir\\using_wide\\mkdir_en_latin";
    my $ja_dir = "$script_dir\\using_wide\\mkdir_ja_日本語";
    my $u8_dir = "$script_dir\\using_wide\\mkdir_ja_日本語♥";
    utf8::upgrade($en_dir);
    utf8::upgrade($ja_dir);
    utf8::upgrade($u8_dir);
    ok( utf8::is_utf8($en_dir) );
    ok( utf8::is_utf8($ja_dir) );
    ok( utf8::is_utf8($u8_dir) );

    my $mkdir = sub {
        my ($enc, $dir) = @_;
        if ($enc) {
            $dir = encode($enc, $dir);
        }
        rmdir($dir);
        my $ret = mkdir($dir);
        rmdir($dir);
        $ret;
    };

    #before: {
    #    # encoded latin1/codepage
    #    ok(  $mkdir->("latin1", $en_dir) );
    #    ok(  $mkdir->("cp932",  $ja_dir) );
    #    ok( !$mkdir->("utf8",   $u8_dir) );
    #
    #    # decoded
    #    ok(  $mkdir->(undef, $en_dir) );
    #    ok( !$mkdir->(undef, $ja_dir) );
    #    ok( !$mkdir->(undef, $u8_dir) );
    #
    #    # encoded utf8
    #    ok(  $mkdir->("utf8", $en_dir) );
    #    ok( !$mkdir->("utf8", $ja_dir) );
    #    ok( !$mkdir->("utf8", $u8_dir) );
    #}

    after: {
        # encoded latin1/codepage
        ok(  $mkdir->("latin1", $en_dir) );
        ok(  $mkdir->("cp932",  $ja_dir) );
        ok(  $mkdir->("utf8",   $u8_dir) );
    
        # decoded
        ok(  $mkdir->(undef, $en_dir) );
        ok(  $mkdir->(undef, $ja_dir) );
        ok(  $mkdir->(undef, $u8_dir) );
    
        # encoded utf8
        ok(  $mkdir->("utf8", $en_dir) );
        ok(  $mkdir->("utf8", $ja_dir) );
        ok(  $mkdir->("utf8", $u8_dir) );
    }
}

rename: {
    my $en_file = "$script_dir\\using_wide\\file_en_latin.txt";
    my $ja_file = "$script_dir\\using_wide\\file_ja_日本語.txt";
    my $u8_file = "$script_dir\\using_wide\\file_ja_日本語♥.txt";
    utf8::upgrade($en_file);
    utf8::upgrade($ja_file);
    utf8::upgrade($u8_file);
    ok( utf8::is_utf8($en_file) );
    ok( utf8::is_utf8($ja_file) );
    ok( utf8::is_utf8($u8_file) );

    my $rename = sub {
        my ($enc, $file) = @_;
        my $src = tempfile();
        my $dst = "${file}_rename";
        if ($enc) {
            $dst = encode($enc, $dst);
        }
        {
            open(my $fh, ">", $src) or die;
        }
        my $ret = rename( $src, $dst );
        unlink($dst);
        $ret;
    };

    after: {
        # encoded latin1/codepage
        ok(  $rename->("latin1", $en_file) );
        ok(  $rename->("cp932",  $ja_file) );
        ok(  $rename->("utf8",   $u8_file) );
    
        # decoded
        ok(  $rename->(undef, $en_file) );
        ok(  $rename->(undef, $ja_file) );
        ok(  $rename->(undef, $u8_file) );
    
        # encoded utf8
        ok(  $rename->("utf8", $en_file) );
        ok(  $rename->("utf8", $ja_file) );
        ok(  $rename->("utf8", $u8_file) );
    }
}

symlink: {
    my $symlink_exists = eval { symlink("",""); 1 };
    ok( !$symlink_exists );
}

truncate: {
    my $en_file = "$script_dir\\using_wide\\file_en_latin.txt";
    my $ja_file = "$script_dir\\using_wide\\file_ja_日本語.txt";
    my $u8_file = "$script_dir\\using_wide\\file_ja_日本語♥.txt";
    utf8::upgrade($en_file);
    utf8::upgrade($ja_file);
    utf8::upgrade($u8_file);
    ok( utf8::is_utf8($en_file) );
    ok( utf8::is_utf8($ja_file) );
    ok( utf8::is_utf8($u8_file) );

    my $truncate = sub {
        my ($enc, $file) = @_;
        if ($enc) {
            $file = encode($enc, $file);
        }
        truncate($file, 0);
    };

    after: {
        # encoded latin1/codepage
        ok( $truncate->("latin1", $en_file) );
        ok( $truncate->("cp932",  $ja_file) );
        ok( $truncate->("utf8",   $u8_file) );
    
        # decoded
        ok( $truncate->(undef, $en_file) );
        ok( $truncate->(undef, $ja_file) );
        ok( $truncate->(undef, $u8_file) );
    
        # encoded utf8
        ok( $truncate->("utf8", $en_file) );
        ok( $truncate->("utf8", $ja_file) );
        ok( $truncate->("utf8", $u8_file) );
    }
}

unlink: {
    my $en_file = "$script_dir\\using_wide\\file_en_latin.txt";
    my $ja_file = "$script_dir\\using_wide\\file_ja_日本語.txt";
    my $u8_file = "$script_dir\\using_wide\\file_ja_日本語♥.txt";
    utf8::upgrade($en_file);
    utf8::upgrade($ja_file);
    utf8::upgrade($u8_file);
    ok( utf8::is_utf8($en_file) );
    ok( utf8::is_utf8($ja_file) );
    ok( utf8::is_utf8($u8_file) );

    my $unlink = sub {
        my ($enc, $file) = @_;
        my $src = tempfile();
        my $dst = "${file}_rename";
        if ($enc) {
            $dst = encode($enc, $dst);
        }
        {
            open(my $fh, ">", $src) or die;
        }
        my $ok_rename = rename( $src, $dst );
        my $ok_unlink = unlink($dst);
        $ok_rename and $ok_unlink;
    };

    after: {
        # encoded latin1/codepage
        ok(  $unlink->("latin1", $en_file) );
        ok(  $unlink->("cp932",  $ja_file) );
        ok(  $unlink->("utf8",   $u8_file) );
    
        # decoded
        ok(  $unlink->(undef, $en_file) );
        ok(  $unlink->(undef, $ja_file) );
        ok(  $unlink->(undef, $u8_file) );
    
        # encoded utf8
        ok(  $unlink->("utf8", $en_file) );
        ok(  $unlink->("utf8", $ja_file) );
        ok(  $unlink->("utf8", $u8_file) );
    }
}

utime: {
    my $en_file = "$script_dir\\using_wide\\file_en_latin.txt";
    my $ja_file = "$script_dir\\using_wide\\file_ja_日本語.txt";
    my $u8_file = "$script_dir\\using_wide\\file_ja_日本語♥.txt";
    utf8::upgrade($en_file);
    utf8::upgrade($ja_file);
    utf8::upgrade($u8_file);
    ok( utf8::is_utf8($en_file) );
    ok( utf8::is_utf8($ja_file) );
    ok( utf8::is_utf8($u8_file) );

    my $utime = sub {
        my ($enc, $file) = @_;
        if ($enc) {
            $file = encode($enc, $file);
        }
        utime(0, 0, $file);
        my $mtime1 = do {
            my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
                $atime,$mtime,$ctime,$blksize,$blocks)
                = stat($file);
            $mtime;
        };
        utime(undef, undef, $file);
        my $mtime2 = do {
            my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
                $atime,$mtime,$ctime,$blksize,$blocks)
                = stat($file);
            $mtime;
        };
        $mtime1 < $mtime2 ? 1 : 0;
    };

    after: {
        # encoded latin1/codepage
        ok(  $utime->("latin1", $en_file) );
        ok(  $utime->("cp932",  $ja_file) );
        ok(  $utime->("utf8",   $u8_file) );
    
        # decoded
        ok(  $utime->(undef, $en_file) );
        ok(  $utime->(undef, $ja_file) );
        ok(  $utime->(undef, $u8_file) );
    
        # encoded utf8
        ok(  $utime->("utf8", $en_file) );
        ok(  $utime->("utf8", $ja_file) );
        ok(  $utime->("utf8", $u8_file) );
    }
}

fttest: {
    my $en_bat = "$script_dir\\using_wide\\echo_self_en_latin.bat";
    my $ja_bat = "$script_dir\\using_wide\\echo_self_ja_日本語.bat";
    my $u8_bat = "$script_dir\\using_wide\\echo_self_ja_日本語♥.bat";
    utf8::upgrade($en_bat);
    utf8::upgrade($ja_bat);
    utf8::upgrade($u8_bat);
    ok( utf8::is_utf8($en_bat) );
    ok( utf8::is_utf8($ja_bat) );
    ok( utf8::is_utf8($u8_bat) );

    my $en_file = "$script_dir\\using_wide\\file_en_latin.txt";
    my $ja_file = "$script_dir\\using_wide\\file_ja_日本語.txt";
    my $u8_file = "$script_dir\\using_wide\\file_ja_日本語♥.txt";
    utf8::upgrade($en_file);
    utf8::upgrade($ja_file);
    utf8::upgrade($u8_file);
    ok( utf8::is_utf8($en_file) );
    ok( utf8::is_utf8($ja_file) );
    ok( utf8::is_utf8($u8_file) );

    my $en_dir = "$script_dir\\using_wide\\dir_en_latin";
    my $ja_dir = "$script_dir\\using_wide\\dir_ja_日本語";
    my $u8_dir = "$script_dir\\using_wide\\dir_ja_日本語♥";
    utf8::upgrade($en_dir);
    utf8::upgrade($ja_dir);
    utf8::upgrade($u8_dir);
    ok( utf8::is_utf8($en_dir) );
    ok( utf8::is_utf8($ja_dir) );
    ok( utf8::is_utf8($u8_dir) );

    my $fttest = sub {
        my ($enc, $path, $success, $fail) = @_;
        $success ||= "";
        $fail    ||= "";
        $success =~ s/\s*//g;
        $fail    =~ s/\s*//g;

        if ($enc) {
            $path = encode($enc, $path);
        }

        for (split(//, $success)) {
            eval "ok(  -$_ \$path, ' -$_ \$path ($enc)')";
        }

        for (split(//, $fail)) {
            eval "ok( !-$_ \$path, '!-$_ \$path ($enc)')";
        }
    };

    {
        my $success = "";
        my $fail    = "";

        $success .= "r"; # -r  File is readable by effective uid/gid.
        $success .= "w"; # -w  File is writable by effective uid/gid.
        $success .= "x"; # -x  File is executable by effective uid/gid.
        $success .= "o"; # -o  File is owned by effective uid.
                         # 
        $success .= "R"; # -R  File is readable by real uid/gid.
        $success .= "W"; # -W  File is writable by real uid/gid.
        $success .= "X"; # -X  File is executable by real uid/gid.
        $success .= "O"; # -O  File is owned by real uid.
                         # 
        $success .= "e"; # -e  File exists.
        $fail    .= "z"; # -z  File has zero size (is empty).
        $success .= "s"; # -s  File has nonzero size (returns size in bytes).
                         # 
        $success .= "f"; # -f  File is a plain file.
        $fail    .= "d"; # -d  File is a directory.
        $fail    .= "l"; # -l  File is a symbolic link.
        $fail    .= "p"; # -p  File is a named pipe (FIFO), or Filehandle is a pipe.
        $fail    .= "S"; # -S  File is a socket.
        $fail    .= "b"; # -b  File is a block special file.
        $fail    .= "c"; # -c  File is a character special file.
        $fail    .= "t"; # -t  Filehandle is opened to a tty.
                         # 
        $fail    .= "u"; # -u  File has setuid bit set.
        $fail    .= "g"; # -g  File has setgid bit set.
        $fail    .= "k"; # -k  File has sticky bit set.
                         # 
        $success .= "T"; # -T  File is an ASCII text file (heuristic guess).
        $fail    .= "B"; # -B  File is a "binary" file (opposite of -T).
                         # 
        $success .= "M"; # -M  Script start time minus file modification time, in days.
        $success .= "A"; # -A  Same for access time.
        $success .= "C"; # -C  Same for inode change time (Unix, may differ for other platforms)

        # encoded latin1/codepage
        $fttest->("latin1" , $en_bat , $success, $fail);
        $fttest->("cp932"  , $ja_bat , $success, $fail);
        $fttest->("utf8"   , $u8_bat , $success, $fail);
    
        # decoded
        $fttest->(undef    , $en_bat , $success, $fail);
        $fttest->(undef    , $ja_bat , $success, $fail);
        $fttest->(undef    , $u8_bat , $success, $fail);
    
        # encoded utf8
        $fttest->("utf8"   , $en_bat , $success, $fail);
        $fttest->("utf8"   , $ja_bat , $success, $fail);
        $fttest->("utf8"   , $u8_bat , $success, $fail);
    }

    {
        my $success = "z";
        my $fail    = "s";

        # encoded latin1/codepage
        $fttest->("latin1" , $en_file , $success, $fail);
        $fttest->("cp932"  , $ja_file , $success, $fail);
        $fttest->("utf8"   , $u8_file , $success, $fail);
    
        # decoded
        $fttest->(undef    , $en_file , $success, $fail);
        $fttest->(undef    , $ja_file , $success, $fail);
        $fttest->(undef    , $u8_file , $success, $fail);
    
        # encoded utf8
        $fttest->("utf8"   , $en_file , $success, $fail);
        $fttest->("utf8"   , $ja_file , $success, $fail);
        $fttest->("utf8"   , $u8_file , $success, $fail);
    }

    {
        my $success = "d";
        my $fail    = "f";

        # encoded latin1/codepage
        $fttest->("latin1" , $en_dir , $success, $fail);
        $fttest->("cp932"  , $ja_dir , $success, $fail);
        $fttest->("utf8"   , $u8_dir , $success, $fail);
    
        # decoded
        $fttest->(undef    , $en_dir , $success, $fail);
        $fttest->(undef    , $ja_dir , $success, $fail);
        $fttest->(undef    , $u8_dir , $success, $fail);
    
        # encoded utf8
        $fttest->("utf8"   , $en_dir , $success, $fail);
        $fttest->("utf8"   , $ja_dir , $success, $fail);
        $fttest->("utf8"   , $u8_dir , $success, $fail);
    }
}

glob: {
    my $en_dir = "$script_dir\\using_wide\\dir_en_latin";
    my $ja_dir = "$script_dir\\using_wide\\dir_ja_日本語";
    my $u8_dir = "$script_dir\\using_wide\\dir_ja_日本語♥";
    utf8::upgrade($en_dir);
    utf8::upgrade($ja_dir);
    utf8::upgrade($u8_dir);
    ok( utf8::is_utf8($en_dir) );
    ok( utf8::is_utf8($ja_dir) );
    ok( utf8::is_utf8($u8_dir) );

    my $glob_count = sub {
        my ($enc, $path) = @_;
        if ($enc) {
            $path = encode($enc, $path);
        }

        my @files = glob("$path\\*");
        0+@files;
    };

    {
        # encoded latin1/codepage
        ok(  $glob_count->("latin1", $en_dir) );
        ok(  $glob_count->("cp932",  $ja_dir) );
        ok(  $glob_count->("utf8",   $u8_dir) );
    
        # decoded
        ok(  $glob_count->(undef, $en_dir) );
        ok(  $glob_count->(undef, $ja_dir) );
        ok(  $glob_count->(undef, $u8_dir) );
    
        # encoded utf8
        ok(  $glob_count->("utf8", $en_dir) );
        ok(  $glob_count->("utf8", $ja_dir) );
        ok(  $glob_count->("utf8", $u8_dir) );
    }

    my $glob_decoded = sub {
        my ($enc, $path) = @_;
        if ($enc) {
            $path = encode($enc, $path);
        }

        my @files = grep { utf8::is_utf8($_) } glob("$path\\*");
        0+@files;
    };

    {
        # encoded latin1/codepage
        ok(  $glob_decoded->("latin1", $en_dir) );
        ok(  $glob_decoded->("cp932",  $ja_dir) );
        ok(  $glob_decoded->("utf8",   $u8_dir) );
    
        # decoded
        ok(  $glob_decoded->(undef, $en_dir) );
        ok(  $glob_decoded->(undef, $ja_dir) );
        ok(  $glob_decoded->(undef, $u8_dir) );
    
        # encoded utf8
        ok(  $glob_decoded->("utf8", $en_dir) );
        ok(  $glob_decoded->("utf8", $ja_dir) );
        ok(  $glob_decoded->("utf8", $u8_dir) );
    }

    my $glob_bracket = sub {
        my ($enc, $path) = @_;
        if ($enc) {
            $path = encode($enc, $path);
        }

        my @files = grep { utf8::is_utf8($_) } <$path\\*>;
        0+@files;
    };

    {
        # encoded latin1/codepage
        ok(  $glob_bracket->("latin1", $en_dir) );
        ok(  $glob_bracket->("cp932",  $ja_dir) );
        ok(  $glob_bracket->("utf8",   $u8_dir) );
    
        # bracket
        ok(  $glob_bracket->(undef, $en_dir) );
        ok(  $glob_bracket->(undef, $ja_dir) );
        ok(  $glob_bracket->(undef, $u8_dir) );
    
        # encoded utf8
        ok(  $glob_bracket->("utf8", $en_dir) );
        ok(  $glob_bracket->("utf8", $ja_dir) );
        ok(  $glob_bracket->("utf8", $u8_dir) );
    }
}

open_and_opendir_and_sysopen: {
    my $u8_file = "$script_dir\\using_wide\\file_ja_日本語♥.txt";
    my $u8_dir  = "$script_dir\\using_wide\\dir_ja_日本語♥";
    utf8::upgrade($u8_file);
    utf8::upgrade($u8_dir);

    ok( open(my $fh, "<", $u8_file) );
    ok( opendir(my $dh, $u8_dir) );
    ok( sysopen(my $fh, $u8_file, 0) );
}

qx_and_system: {
    my $en_bat = "$script_dir\\using_wide\\echo_self_en_latin.bat";
    my $ja_bat = "$script_dir\\using_wide\\echo_self_ja_日本語.bat";
    my $u8_bat = "$script_dir\\using_wide\\echo_self_ja_日本語♥.bat";
    utf8::upgrade($en_bat);
    utf8::upgrade($ja_bat);
    utf8::upgrade($u8_bat);
    ok( utf8::is_utf8($en_bat) );
    ok( utf8::is_utf8($ja_bat) );
    ok( utf8::is_utf8($u8_bat) );

    my $qx = sub {
        my $bat = shift;
        my $str = qx($bat);
        $str = decode('cp932', $str);

        my $match = do {
            $bat =~ m/\\([^\\]+)$/ or return;
            $1;
        };

        length($str) and $str =~ m/$match/;
    };

    after: {
        ok( $qx->($en_bat) );
        ok( $qx->($ja_bat) );
        #ok( $qx->($u8_bat) );
    }

    my $system = sub {
        my $bat = shift;

        if (${^TAINT}) {
            eval { system($bat) };
            ok( $@, "Insecure dependency in chdir while running with -T switch" );
        }
        else {
            system($bat) == 0;
        }
    };

    after: {
        ok( $system->($en_bat) );
        ok( $system->($ja_bat) );
        ok( $system->($u8_bat) );
    }
}

# Perl5Unleashed
#readlink: {
#    my $en_link = "$script_dir\\using_wide\\link_en_latin.txt";
#    my $ja_link = "$script_dir\\using_wide\\link_ja_日本語.txt";
#    my $u8_link = "$script_dir\\using_wide\\link_ja_日本語♥.txt";
#    utf8::upgrade($en_link);
#    utf8::upgrade($ja_link);
#    utf8::upgrade($u8_link);
#    ok( utf8::is_utf8($en_link) );
#    ok( utf8::is_utf8($ja_link) );
#    ok( utf8::is_utf8($u8_link) );
#
#    my $link = sub {
#        my ($enc, $file) = @_;
#        my $src = tempfile();
#        my $dst = $file;
#        if ($enc) {
#            $dst = encode($enc, $dst);
#        }
#        {
#            open(my $fh, ">", $src) or die;
#        }
#        unlink($dst);
#        link($src,$dst);
#        readlink($dst) or die $!; # Inappropriate I/O control operation
#    };
#
#    after: {
#        # encoded latin1/codepage
#        ok(  $link->("latin1", $en_link) );
#        ok(  $link->("cp932",  $ja_link) );
#        ok(  $link->("utf8",   $u8_link) );
#    
#        # decoded
#        ok(  $link->(undef, $en_link) );
#        ok(  $link->(undef, $ja_link) );
#        ok(  $link->(undef, $u8_link) );
#    
#        # encoded utf8
#        ok(  $link->("utf8", $en_link) );
#        ok(  $link->("utf8", $ja_link) );
#        ok(  $link->("utf8", $u8_link) );
#    }
#}

ENV: {
    utf8: {
        my @utf8_keys   = grep { utf8::is_utf8($_) } keys %ENV;
        my @utf8_values = grep { utf8::is_utf8($_) } keys %ENV;

        ok( @utf8_keys );
        ok( @utf8_values );
    }

    getenv_and_putenv: {
        my @keys1 = keys %ENV;
        ok( !exists $ENV{ undef() } );
        my @keys2 = keys %ENV;
        ok( @keys1 == @keys2 );


        # CPAN-1.9800/lib/CPAN/Distribution.pm:1905
        #if ($pl_env) {
        #    for my $e (keys %$pl_env) {
        #        $ENV{$e} = $pl_env->{$e};
        #    }
        #}
        bug: {
            for (keys %ENV) {
                $ENV{$_} = $ENV{$_}."";
            }
            my @keys3 = keys %ENV;
            ok( @keys1 == @keys3 );
            ok( !exists $ENV{ undef() } );
            my @keys4 = keys %ENV;
            ok( @keys1 == @keys4 ) or warn Dumper \%ENV;

            #diag( 0+@keys1 );
            #system(qq{$^X -e "print 0+(keys %ENV); use Data::Dumper; local \$Data::Dumper::Sortkeys=1; print Dumper(\\%ENV)"});
        }
    }

    win32_spawnvp: {
        my $dst = tempfile();
        open(my $fh, ">", $dst);
        print $fh qq{#!perl\nprint "Hello World.";\n};
        close $fh;

        my $MAX_PATH = 260;

        my $long_arg = 'a' x $MAX_PATH;

        my $out;
        my $err;
        my @command = ($^X, '-I', $long_arg, $dst);

        use IPC::Open3;
        my $pid = open3(
            '<&STDIN', $out, $err,
            @command
        );
        ok( $pid );
        my $line = <$out>;
        ok( $line );
        is( $line, "Hello World.", "Hello World.");
    }
}

opendir: {
    my $en_dir = "$script_dir\\using_wide\\dir_en_latin";
    my $ja_dir = "$script_dir\\using_wide\\dir_ja_日本語";
    my $u8_dir = "$script_dir\\using_wide\\dir_ja_日本語♥";
    utf8::upgrade($en_dir);
    utf8::upgrade($ja_dir);
    utf8::upgrade($u8_dir);
    ok( utf8::is_utf8($en_dir) );
    ok( utf8::is_utf8($ja_dir) );
    ok( utf8::is_utf8($u8_dir) );

    my $opendir = sub {
        my ($enc, $dir) = @_;
        if ($enc) {
            $dir = encode($enc, $dir);
        }
        opendir(my $dh, $dir);
    };

    after: {
        # encoded latin1/codepage
        ok(  $opendir->("latin1", $en_dir) );
        ok(  $opendir->("cp932",  $ja_dir) );
        ok(  $opendir->("utf8",   $u8_dir) );
    
        # decoded
        ok(  $opendir->(undef, $en_dir) );
        ok(  $opendir->(undef, $ja_dir) );
        ok(  $opendir->(undef, $u8_dir) );
    
        # encoded utf8
        ok(  $opendir->("utf8", $en_dir) );
        ok(  $opendir->("utf8", $ja_dir) );
        ok(  $opendir->("utf8", $u8_dir) );
    }
}

readdir: {
    my $en_dir = "$script_dir\\using_wide\\dir_en_latin";
    my $ja_dir = "$script_dir\\using_wide\\dir_ja_日本語";
    my $u8_dir = "$script_dir\\using_wide\\dir_ja_日本語♥";
    utf8::upgrade($en_dir);
    utf8::upgrade($ja_dir);
    utf8::upgrade($u8_dir);
    ok( utf8::is_utf8($en_dir) );
    ok( utf8::is_utf8($ja_dir) );
    ok( utf8::is_utf8($u8_dir) );

    my $readdir = sub {
        my ($enc, $dir) = @_;
        if ($enc) {
            $dir = encode($enc, $dir);
        }
        my @files1 = do {
            opendir(my $dh, $dir) or return;
            readdir($dh);
        };
        if (@files1) {
            my @decoded = grep { utf8::is_utf8($_) } @files1;
            if (@decoded) {
                return 1;
            }
        }
        return;
    };

    after: {
        # encoded latin1/codepage
        ok(  $readdir->("latin1", $en_dir) );
        ok(  $readdir->("cp932",  $ja_dir) );
        ok(  $readdir->("utf8",   $u8_dir) );
    
        # decoded
        ok(  $readdir->(undef, $en_dir) );
        ok(  $readdir->(undef, $ja_dir) );
        ok(  $readdir->(undef, $u8_dir) );
    
        # encoded utf8
        ok(  $readdir->("utf8", $en_dir) );
        ok(  $readdir->("utf8", $ja_dir) );
        ok(  $readdir->("utf8", $u8_dir) );
    }
}

getcwd: {
    my $cwd = Cwd::getcwd();

    my $en_dir = "$script_dir\\using_wide\\dir_en_latin";
    my $ja_dir = "$script_dir\\using_wide\\dir_ja_日本語";
    my $u8_dir = "$script_dir\\using_wide\\dir_ja_日本語♥";
    utf8::upgrade($en_dir);
    utf8::upgrade($ja_dir);
    utf8::upgrade($u8_dir);
    ok( utf8::is_utf8($en_dir) );
    ok( utf8::is_utf8($ja_dir) );
    ok( utf8::is_utf8($u8_dir) );

    my $getcwd = sub {
        my ($enc, $dir_orig) = @_;

        my $dir = $dir_orig;
        if ($enc) {
            $dir = encode($enc, $dir_orig);
        }
        if ($dir =~ m/\?/) {
            return chdir($dir) ? 0 : 1;
        }
        else {
            chdir($dir) or return;
            my $cwd2 = Cwd::getcwd();
            my $pattern = do {
                my $str = $dir_orig;
                $str =~ s/\\/\//g;
                $str =~ s/\.\.\///;
                $str;
            };
            return $cwd2 =~ m/\Q$pattern\E$/;
        }
    };

    my @dirs = ($en_dir, $ja_dir, $u8_dir);
    my @encs = (undef, qw(latin1 cp932 utf8));

    for my $dir (@dirs) {
        for my $enc (@encs) {
            ok(  $getcwd->($enc, $dir) );
            ok(  chdir($cwd), "cwd" );
        }
    }
}

argvw: {
    {
        my $out = qx{$^X -e "use Encode; print encode('cp932', join(' ', \@ARGV))" english 日本語};
        is( $out, encode("cp932", "english 日本語"));
    }

    use IPC::Open2;
    my @cmds = (
        [ qq{$^X -e "use Encode; print encode('cp932', join(' ', \@ARGV))" english 日本語}       ],
        [ $^X, "-e", q{use Encode; print encode('cp932', join(' ', @ARGV))}, "english", "日本語" ],
    );
    for (@cmds) {
        my @cmd = @$_;
        my ($pid, $stdout, $stdin, $out);
        my $pid = open2($stdout, $stdin, @cmd);
        waitpid( $pid, 0 );
        $out = do { local $/; <$stdout> }; 
        is( $out, encode("cp932", "english 日本語"));
    }
}

file_copy: {
    my $en_file = "$script_dir\\using_wide\\file_en_latin.txt";
    my $ja_file = "$script_dir\\using_wide\\file_ja_日本語.txt";
    my $u8_file = "$script_dir\\using_wide\\file_ja_日本語♥.txt";
    utf8::upgrade($en_file);
    utf8::upgrade($ja_file);
    utf8::upgrade($u8_file);
    ok( utf8::is_utf8($en_file) );
    ok( utf8::is_utf8($ja_file) );
    ok( utf8::is_utf8($u8_file) );

    my @copied;

    require File::Copy;
    my $copy = sub {
        my ($enc, $file) = @_;
        if ($enc) {
            $file = encode($enc, $file);
        }

        my $src = $file;
        my $dst = $src =~ s/\.txt$/2.txt/r or die;

        push @copied, $dst;

        if ( -f $src ) {
            if ( !-f $dst ) {
                if ( File::Copy::copy($src,$dst) ) {
                    if ( -f $dst ) {
                        unlink $dst;
                        return 1;
                    }
                    else {
                        diag('-f $dst');
                    }
                }
                else {
                    diag('copy($src,$dst)');
                }
            }
            else {
                diag('!-f $dst');
            }
        }
        else {
            diag('-f $src');
        }

        return 0;
    };

    #before: {
    #    # encoded latin1/codepage
    #    ok(  $copy->("latin1", $en_file) );
    #    ok(  $copy->("cp932",  $ja_file) );
    #    ok( !$copy->("utf8",   $u8_file) );
    
    #    # decoded
    #    ok(  $copy->(undef, $en_file) );
    #    ok( !$copy->(undef, $ja_file) );
    #    ok( !$copy->(undef, $u8_file) );
    
    #    # encoded utf8
    #    ok(  $copy->("utf8", $en_file) );
    #    ok( !$copy->("utf8", $ja_file) );
    #    ok( !$copy->("utf8", $u8_file) );
    #}

    after: {
        # encoded latin1/codepage
        ok(  $copy->("latin1", $en_file) );
        ok(  $copy->("cp932",  $ja_file) );
        ok(  $copy->("utf8",   $u8_file) );
    
        # decoded
        ok(  $copy->(undef, $en_file) );
        ok(  $copy->(undef, $ja_file) );
        ok(  $copy->(undef, $u8_file) );
    
        # encoded utf8
        ok(  $copy->("utf8", $en_file) );
        ok(  $copy->("utf8", $ja_file) );
        ok(  $copy->("utf8", $u8_file) );
    }

    END {
        for (@copied) {
            unlink $_;
        }
    }
}

__END__

http://perldoc.perl.org/perlunicode.html#When-Unicode-Does-Not-Happen

chdir, chmod, chown, chroot, exec, link, lstat, mkdir, rename, rmdir, stat, symlink, truncate, unlink, utime, -X
%ENV
glob (aka the <*>)
open, opendir, sysopen
qx (aka the backtick operator), system
readdir, readlink
