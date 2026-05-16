use strict;
use warnings;
use utf8;
binmode(STDOUT, ":encoding(UTF-8)");

my $total_cn = 0;
my $total_punct = 0;
my %file_stats;

my @files = glob("contents/*.tex");

foreach my $file (@files) {
    next unless -f $file;
    open(my $fh, "<:encoding(UTF-8)", $file) or next;
    my $text = do { local $/; <$fh> };
    close $fh;

    # Remove comments
    $text =~ s/^[ \t]*%.*$//gm;

    # Remove LaTeX commands with arguments
    1 while $text =~ s/\\[a-zA-Z@]+\{[^{}]*\}//g;
    # Remove simple commands
    $text =~ s/\\[a-zA-Z@]+//g;
    # Remove math mode
    $text =~ s/\x{24}[^\x{24}]*\x{24}//g;
    $text =~ s/\\\[.*?\\\]//gs;
    # Remove begin/end
    $text =~ s/\\begin\{[^}]*\}//g;
    $text =~ s/\\end\{[^}]*\}//g;

    # Count CJK characters
    my $cn = () = $text =~ /[\x{4e00}-\x{9fff}\x{3400}-\x{4dbf}]/g;
    my $punct = () = $text =~ /[\x{3000}-\x{303f}\x{ff00}-\x{ffef}]/g;

    my $basename = $file;
    $basename =~ s{.*/}{};
    $file_stats{$basename} = { cn => $cn, punct => $punct };
    $total_cn += $cn;
    $total_punct += $punct;
}

print "=" x 70 . "\n";
printf("%-35s %8s %8s %8s\n", "File", "CN Chars", "Punct", "Total");
print "-" x 70 . "\n";
foreach my $f (sort keys %file_stats) {
    my $s = $file_stats{$f};
    printf("%-35s %8d %8d %8d\n", $f, $s->{cn}, $s->{punct}, $s->{cn} + $s->{punct});
}
print "-" x 70 . "\n";
printf("%-35s %8d %8d %8d\n", "TOTAL (contents/)", $total_cn, $total_punct, $total_cn + $total_punct);
print "=" x 70 . "\n";
