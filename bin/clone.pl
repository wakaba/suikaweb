use strict;
use warnings;
use Path::Tiny;

my $map_path = path (shift or die);
my $docroot_path = path (shift or die)->absolute;

for (split /\x0A/, $map_path->slurp) {
  my ($path, $url) = split /\s+/, $_, 2;
  next unless defined $url;
  
  my $repo_path = $docroot_path->child ($path);
  warn "$url -> $repo_path\n";

  if ($repo_path->child ('.dummy')->is_file) {
    $repo_path->child ('.dummy')->remove;
  }
  if ($repo_path->is_file and not -s $repo_path) {
    $repo_path->remove;
  }
  if ($repo_path->child ('.git')->is_dir) {
    warn "skipped\n";
  } else {
    (system 'git', 'clone', '--depth=1', $url, $repo_path) == 0 or die "Failed: $url";
  }

  (system './perl', 'local/bin/git-set-timestamp.pl', $repo_path) == 0
      or die "Failed git-set-timestamp $repo_path";
}
