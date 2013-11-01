//
//  PBSubscriptionHeuristics.m
//  Photoblogs
//
//  Created by Mircea Avram on 11-02-25.
//  Copyright 2011 Beaufield Atelier. All rights reserved.
//

#import "PBSubscriptionHeuristics.h"
#import "PBAppDelegate.h"


@implementation PBSubscription (PBSubscriptionHeuristics)


- (BOOL)isKnownPhotoblog {
    
    if ([[self identifier] isEqualToString:@"feed/http://feeds.feedburner.com/chromasia"] ||
        [[self identifier] isEqualToString:@"feed/http://www.chromasia.com/iblog/index.xml"] ||
        [[self identifier] isEqualToString:@"feed/http://brunoat.com/photoblog/index.php?x=rss"] ||
        [[self identifier] isEqualToString:@"feed/http://wvs.topleftpixel.com/index_fullfeed.rdf"] ||
        [[self identifier] isEqualToString:@"feed/http://feeds.feedburner.com/SexnotSex"] ||
        [[self identifier] isEqualToString:@"feed/http://moodaholic.com/rss"] ||
        [[self identifier] isEqualToString:@"feed/http://feeds.feedburner.com/MADPHOTOWORLD"] ||
        [[self identifier] isEqualToString:@"feed/http://feeds.feedburner.com/DeceptiveMedia"] ||
        [[self identifier] isEqualToString:@"feed/http://mute.rigent.com/rss/mutefeed.xml"] ||
        [[self identifier] isEqualToString:@"feed/http://weliveyoung.blogspot.com/feeds/posts/default"] ||
        [[self identifier] isEqualToString:@"feed/http://www.id7.co.uk/portfolio/atom.xml"] ||
        [[self identifier] isEqualToString:@"feed/http://sixty4-middle-kingdom.blogspot.com/feeds/posts/default"] ||
        [[self identifier] isEqualToString:@"feed/http://alovesupreme.aminus3.com/feed/images/"] ||
        [[self identifier] isEqualToString:@"feed/http://feeds.feedburner.com/Amemoryintheraw"] ||
        [[self identifier] isEqualToString:@"feed/http://maryvrobinson.blogspot.com/feeds/posts/default"] ||
        [[self identifier] isEqualToString:@"feed/http://www.paulison.com/photoblog/index.php?x=rss&PHPSESSID=f10ab3cff1697d4d158f7a97686f8eb9"] ||
        [[self identifier] isEqualToString:@"feed/http://www.durhamtownship.com/index.rdf"] ||
        [[self identifier] isEqualToString:@"feed/http://www.amypink.com/en/feed/"] ||
        [[self identifier] isEqualToString:@"feed/http://artsponge.wordpress.com/feed/"] ||
        [[self identifier] isEqualToString:@"feed/http://bloodoftheyoung.tumblr.com/rss"] ||
        [[self identifier] isEqualToString:@"feed/http://www.bontemaru.com/index.php?x=rss"] ||
        [[self identifier] isEqualToString:@"feed/http://www.booooooom.com/feed/"] ||
        [[self identifier] isEqualToString:@"feed/http://www.smarts.nl/BouncingLight/index.php?x=rss"] ||
        [[self identifier] isEqualToString:@"feed/http://www.slehmann.de/photoblog/index.php?x=rss&PHPSESSID=5pb4cbrc2nkm6g1fkdvdm0qtm4"] ||
        [[self identifier] isEqualToString:@"feed/http://comingupstrong.blogspot.com/feeds/posts/default"] ||
        [[self identifier] isEqualToString:@"feed/http://www.creamybokeh.com/index.php?x=atom"] ||
        [[self identifier] isEqualToString:@"feed/http://wvs.topleftpixel.com/index_fullfeed.rdf"] ||
        [[self identifier] isEqualToString:@"feed/http://www.dillonpic.com/blog/feeds/rss.xml"] ||
        [[self identifier] isEqualToString:@"feed/http://feeds.feedburner.com/DeceptiveMedia"] ||
        [[self identifier] isEqualToString:@"feed/http://feeds2.feedburner.com/diskursdisko"] ||
        [[self identifier] isEqualToString:@"feed/http://luciecamp.tumblr.com/rss"] ||
        [[self identifier] isEqualToString:@"feed/http://drowningintheflame.blogspot.com/feeds/posts/default"] ||
        [[self identifier] isEqualToString:@"feed/http://enriquevidalphoto.com/photoblog/index.php?x=rss"] ||
        [[self identifier] isEqualToString:@"feed/http://eyeswideshut.my-expressions.com/atom_5458.xml"] ||
        [[self identifier] isEqualToString:@"feed/http://from10to300mm.com/feed/entries/atom"] ||
        [[self identifier] isEqualToString:@"feed/http://www.fatale-femmes.com/feeds/posts/default"] ||
        [[self identifier] isEqualToString:@"feed/http://feeds2.feedburner.com/FeaverishPhotographyBlog"] ||
        [[self identifier] isEqualToString:@"feed/http://feeds.feedburner.com/GuidedMunich"] ||
        [[self identifier] isEqualToString:@"feed/http://feeds.feedburner.com/HeadFullOfSky"] ||
        [[self identifier] isEqualToString:@"feed/http://headphoneland.my-expressions.com/atom_4900.xml"] ||
        [[self identifier] isEqualToString:@"feed/http://iamsamr.wordpress.com/feed/"] ||
        [[self identifier] isEqualToString:@"feed/http://blog.ilovethatphoto.net/feed/"] ||
        [[self identifier] isEqualToString:@"feed/http://alinatodea.ro/photoblog/?feed=rss2"] ||
        [[self identifier] isEqualToString:@"feed/http://www.justingaynor.com/index.php?x=rss"] ||
        [[self identifier] isEqualToString:@"feed/http://lastnightsparty.com/?feed=rss2"] ||
        [[self identifier] isEqualToString:@"feed/http://dcorrin.aminus3.com/feed/images/"] ||
        [[self identifier] isEqualToString:@"feed/http://lifevicarious.com/pixelpost/index.php?x=rss"] ||
        [[self identifier] isEqualToString:@"feed/http://nearproximity.blogspot.com/feeds/posts/default"] ||
        [[self identifier] isEqualToString:@"feed/http://feeds.feedburner.com/MADPHOTOWORLD"] ||
        [[self identifier] isEqualToString:@"feed/http://maryrobinson.tumblr.com/rss"] ||
        [[self identifier] isEqualToString:@"feed/http://milou.phototage.com/atom_4159.xml"] ||
        [[self identifier] isEqualToString:@"feed/http://moodaholic.com/rss"] ||
        [[self identifier] isEqualToString:@"feed/http://mute.rigent.com/rss/mutefeed.xml"] ||
        [[self identifier] isEqualToString:@"feed/http://seasonsinthesun.tumblr.com/rss"] ||
        [[self identifier] isEqualToString:@"feed/http://www.mysteryme.com/index.php?x=rss"] ||
        [[self identifier] isEqualToString:@"feed/http://nikolinelr.blogspot.com/feeds/posts/default"] ||
        [[self identifier] isEqualToString:@"feed/http://nishe.tumblr.com/rss"] ||
        [[self identifier] isEqualToString:@"feed/http://nishe.net/index.php/feed/"] ||
        [[self identifier] isEqualToString:@"feed/http://noinever.blogspot.com/feeds/posts/default"] ||
        [[self identifier] isEqualToString:@"feed/http://feeds.feedburner.com/nofound"] ||
        [[self identifier] isEqualToString:@"feed/http://feeds.feedburner.com/Noupe"] ||
        [[self identifier] isEqualToString:@"feed/http://www.photoflog.org/index.php?x=atom"] ||
        [[self identifier] isEqualToString:@"feed/http://www.markpower.me.uk/photoblog/index.php?x=rss"] ||
        [[self identifier] isEqualToString:@"feed/http://picdit.wordpress.com/feed/"] ||
        [[self identifier] isEqualToString:@"feed/http://pixeldreamer.de/index.php?x=atom"] ||
        [[self identifier] isEqualToString:@"feed/http://www.blindphotography.ca/index.php?x=atom"] ||
        [[self identifier] isEqualToString:@"feed/http://www.krisvdv.net/pixelpost/index.php?x=rss"] ||
        [[self identifier] isEqualToString:@"feed/http://polydactyle.aminus3.com/feed/images/"] ||
        [[self identifier] isEqualToString:@"feed/http://www.positive-magazine.com/feed/"] ||
        [[self identifier] isEqualToString:@"feed/http://nikoline.tumblr.com/rss"] ||
        [[self identifier] isEqualToString:@"feed/http://feeds2.feedburner.com/purple-diary/rss"] ||
        [[self identifier] isEqualToString:@"feed/http://www.recordisphotography.com/feed/"] ||
        [[self identifier] isEqualToString:@"feed/http://sensitivelight.com/rss.xml"] ||
        [[self identifier] isEqualToString:@"feed/http://sexnotsex.tumblr.com/rss"] ||
        [[self identifier] isEqualToString:@"feed/http://feeds.feedburner.com/SexnotSex"] ||
        [[self identifier] isEqualToString:@"feed/http://sparkle.photobug.org/index.xml"] ||
        [[self identifier] isEqualToString:@"feed/http://feeds2.feedburner.com/squarepicture"] ||
        [[self identifier] isEqualToString:@"feed/http://www.sas-foto.de/index.php?/fotoblog/rss_2.0/"] ||
        [[self identifier] isEqualToString:@"feed/http://syntheticpubes.com/rss"] ||
        [[self identifier] isEqualToString:@"feed/http://www.tamaralichtenstein.com/rss"] ||
        [[self identifier] isEqualToString:@"feed/http://feeds.boston.com/boston/bigpicture/index"] ||
        [[self identifier] isEqualToString:@"feed/http://thelandbetweenhereandmountains.blogspot.com/feeds/posts/default"] ||
        [[self identifier] isEqualToString:@"feed/http://www.theplasticlens.com/feed/"] ||
        [[self identifier] isEqualToString:@"feed/http://www.treeswing.net/index.php?x=rss"] ||
        [[self identifier] isEqualToString:@"feed/http://feeds.feedburner.com/yayeveryday"] ||
        [[self identifier] isEqualToString:@"feed/http://zenith9.my-expressions.com/atom_4822.xml"] ||
        [[self identifier] isEqualToString:@"feed/http://nizhalkoothu.blogspot.com/feeds/posts/default"] ||
        [[self identifier] isEqualToString:@"feed/http://feeds.feedburner.com/Designzine"] ||
        [[self identifier] isEqualToString:@"feed/http://api.flickr.com/services/feeds/photos_public.gne?id=27453474@N02&lang=en-us&format=atom"] ||
        [[self identifier] isEqualToString:@"feed/http://www.accessible.de/pixelpost/index.php?x=rss"] ||
        [[self identifier] isEqualToString:@"feed/http://www.dianevarner.com/dailywalks.xml"] ||
        [[self identifier] isEqualToString:@"feed/http://feeds.feedburner.com/abduzeedo"] ||
        [[self identifier] isEqualToString:@"feed/http://www.photoschau.de/index.php?x=rss"] ||
        [[self identifier] isEqualToString:@"feed/http://feeds.feedburner.com/apartmenttherapy/thekitchn"] ||
        [[self identifier] isEqualToString:@"feed/http://www.latartinegourmande.com/feed/"] ||
        [[self identifier] isEqualToString:@"feed/http://framedandshot.com/feed/"] ||
        [[self identifier] isEqualToString:@"feed/http://www.id7.co.uk/portfolio/atom.xml"]) {
        return YES;
    }
    
    
    
    return NO;
}



@end
