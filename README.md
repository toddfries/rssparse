dependencies:
 p5-MIME-Charset

There is a p5-HTML-FormatText-WithLinks out there, but I was not
pleased with all of its output.

So, I wrote my own.

The initial use case was 'h2t' which I use via mutt to view text/html inline.

I also wanted to have a 'sample' application that would utilize a
sqlite database to parse rss feeds and email me any 'news'.  This is what
r2e is all about.

Someday I'll document these two utilities in man format. Until then, see
sample output in README.samples.

Please let me know if anyone has advice on the whole conversion to/from unicode
and treatment of non us-ascii characters.  I want to learn, I just lack
sufficient pointers.

Thanks,
-- 
Todd Fries .. todd@fries.net

 ____________________________________________
|                                            \  1.636.410.0632 (voice)
| Free Daemon Consulting, LLC                \  1.405.227.9094 (voice)
| http://FreeDaemonConsulting.com            \  1.866.792.3418 (FAX)
| PO Box 16169, Oklahoma City, OK 73113      \  sip:freedaemon@ekiga.net
| "..in support of free software solutions." \  sip:4052279094@ekiga.net
 \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
                                                 
              37E7 D3EB 74D0 8D66 A68D  B866 0326 204E 3F42 004A
                        http://todd.fries.net/pgp.txt
