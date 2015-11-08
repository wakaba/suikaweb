use strict;
use warnings;
while (<>) {
  if (/^(\S+)\s+(\S+)$/) {
    my $path = $1;
    my $url = $2;
    $path =~ s/\.git$//;

    my $type = $url =~ /github/ ? 'github' : 'bitbucket';
    print qq{Redirect 302 /gate/git/wi/$path/ $url/{$type}\n};
    print qq{Redirect 302 /gate/git/wi/$path.git/ $url/{$type}\n};
    print qq{Redirect 302 /gate/git/bare/$path.git/ $url.git/\n};
  }
}
