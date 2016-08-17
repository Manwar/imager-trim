package Imager::Trim;

use parent 'Imager';
use Imager::Color;
use warnings;
use strict;

sub fuzz {
    my ($self, $value) = @_;
    if (defined $value and ($value+0) > 0) {
        $self->{fuzz} = $value+0;
    } elsif (!$self->{fuzz}) {
        $self->{fuzz} = 0;
    }
    return $self->{fuzz};
}

sub color {
    my ($self, @values) = @_;
    if (@_ > 1) {
        if (ref($values[0]) eq 'Imager::Color') {
            $self->{color} = $values[0];
        } else {
            $self->{color} = Imager::Color->new(@values);
        }
    } elsif (!$self->{color}) {
        $self->{color} = $self->getpixel( x => 0, y => 0 );        
    }
    return $self->{color};
}

sub trim_top {
    return shift->{trim_top};
}

sub trim_left {
    return shift->{trim_left};
}

sub trim_right {
    return shift->{trim_right};
}

sub trim_bottom {
    return shift->{trim_bottom};
}

sub _match_colors {
    my ($self, $x, $y) = @_;

    my ($color1_red, $color1_green, $color1_blue) = $self->color->rgba();
    my ($color2_red, $color2_green, $color2_blue) = $self->getpixel( x => $x, y => $y )->rgba();

    return 1 if
        ($color1_red < ($color2_red - $self->fuzz) or $color1_red > ($color2_red + $self->fuzz))
        and ($color1_green < ($color2_green - $self->fuzz) or $color1_green > ($color2_green + $self->fuzz))
        and ($color1_blue < ($color2_blue - $self->fuzz) or $color1_blue > ($color2_blue + $self->fuzz))
    ;
}

sub trim {
    my ($self, %params) = @_;

    $self->fuzz($params{fuzz});

    $self->color($params{color});

    my $top = 0;
    my $left = 0;
    my $right = $self->getwidth();
    my $bottom = $self->getheight();

    for (my $y = $top; $y < $bottom; $y++) {
        my $match = 0;
        for (my $x = $left; $x < $right; $x++) {
            if ($self->_match_colors($x, $y)) {
                $match = 1;
                last;
            }
        }
        if ($match) {
            $top = $y;
            last;
        }
    }

    for (my $y = $bottom; $y > $top; $y--) {
        my $match = 0;
        for (my $x = $left; $x < $right; $x++) {
            if ($self->_match_colors($x, $y-1)) {
                $match = 1;
                last;
            }
        }
        if ($match) {
            $bottom = $y;
            last;
        }
    }

    for (my $x = $left; $x < $right; $x++) {
        my $match = 0;
        for (my $y = $top; $y < $bottom; $y++) {
            if ($self->_match_colors($x, $y)) {
                $match = 1;
                last;
            }
        }
        if ($match) {
            $left = $x;
            last;
        }
    }

    for (my $x = $right; $x > $left; $x--) {
        my $match = 0;
        for (my $y = $top; $y < $bottom; $y++) {
            if ($self->_match_colors($x-1, $y)) {
                $match = 1;
                last;
            }
        }
        if ($match) {
            $right = $x;
            last;
        }
    }

    $self->{trim_top} = $top;
    $self->{trim_left} = $left;
    $self->{trim_right} = $right;
    $self->{trim_bottom} = $bottom;

    return $self->crop(
        left => $self->trim_left,
        right => $self->trim_right,
        top => $self->trim_top,
        bottom => $self->trim_bottom,
    );
}

1;

# ABSTRACT: automatic cropping for images using Imager.

# VERSION

=head1 SYNOPSIS

    use Imager::Trim;

    my $imager = Imager::Trim->new( file => 'image.jpg' )
        or die "Cannot open file: ", Imager->errstr();

    my $cropped_image = $imager->trim( fuzz => 50 );

The image can be saved or used just as an ordinary C<Imager> would:

    $cropped_image->write( file => 'cropped_image.jpg' );

By default the first pixel from top left is used for automatic cropping, however you can provide yourself an C<Imager::Color> for custom action:

    use Imager::Color

    # White
    my $color = Imager::Color->new("#FFFFFF");

    my $color_cropped_image = $imager->trim( color => $color );

See cropped positions:

    my $trim_top = $cropped_image->trim_top;
    my $trim_left = $cropped_image->trim_left;
    my $trim_right = $cropped_image->trim_right;
    my $trim_bottom = $cropped_image->trim_bottom;

You can even do the cropping manually using Imager (on this example, we're leaving 2px extra space around the automatically cropped image if there's 5px margin):

    my $manually_cropped_image = $imager->crop(
        top => ($trim_top > 5) ? ($trim_top - 2) : $trim_top,
        left => ($trim_left > 5) ? ($trim_left - 2) : $trim_left,
        right => ($trim_right > 5) ? ($trim_right - 2) : $trim_right,
        bottom => ($trim_bottom > 5) ? ($trim_bottom - 2) : $trim_bottom
    );

=head1 DESCRIPTION

This module extends C<Imager> to allow automatic cropping of images. The method is similar as used in image editors (e.g. "magic wand") or with ImageMagick's "trim" (e.g. 'convert image.jpg -fuzz 50 -background white -trim cropped_image.jpg').

=head1 SEE ALSO

L<http://imager.perl.org/>

=head1 AUTHOR

Jussi Kinnula <spot@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2016 by Jussi Kinnula.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
