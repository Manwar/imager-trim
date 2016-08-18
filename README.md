# NAME

Imager::Trim - automatic cropping for images using Imager.

# VERSION

version 0.006

# SYNOPSIS

    use Imager::Trim;

    my $imager = Imager::Trim->new( file => 'image.jpg' )
        or die "Cannot open file: ", Imager::Trim->errstr();

    my $cropped_image = $imager->trim( fuzz => 50 );

    $cropped_image->write( file => 'cropped_image.jpg' );

By default the first pixel from top left is used for automatic cropping, however you can provide yourself an `Imager::Color` for custom action:

    use Imager::Trim;
    use Imager::Color;

    my $white_color = Imager::Color->new("#FFFFFF");
    my $imager = Imager::Trim->new( file => 'image_with_white_background.jpg' );
    my $color_cropped_image = $imager->trim( color => $white_color );

You can even do the cropping manually using Imager (on this example, we're leaving 2px extra space around the automatically cropped image if there's 5px margin):

    use Imager::Trim;

    my $imager = Imager::Trim->new( file => 'image.jpg' );
    my $cropped_image = $imager->trim();

    my $trim_top = $cropped_image->trim_top;
    my $trim_left = $cropped_image->trim_left;
    my $trim_right = $cropped_image->trim_right;
    my $trim_bottom = $cropped_image->trim_bottom;

    my $manually_cropped_image = $imager->crop(
        top => ($trim_top > 5) ? ($trim_top - 2) : $trim_top,
        left => ($trim_left > 5) ? ($trim_left - 2) : $trim_left,
        right => ($trim_right > 5) ? ($trim_right - 2) : $trim_right,
        bottom => ($trim_bottom > 5) ? ($trim_bottom - 2) : $trim_bottom
    );

# DESCRIPTION

This module extends `Imager` to allow automatic cropping of images. The method is similar as used in image editors (e.g. "magic wand") or with ImageMagick's "trim" (e.g. 'convert image.jpg -fuzz 50 -background white -trim cropped\_image.jpg').

# SEE ALSO

[http://imager.perl.org/](http://imager.perl.org/)

# AUTHOR

Jussi Kinnula <spot@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2016 by Jussi Kinnula.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
