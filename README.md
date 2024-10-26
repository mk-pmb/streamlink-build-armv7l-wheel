
<!--#echo json="package.json" key="name" underline="=" -->
streamlink-build-armv7l-wheel
=============================
<!--/#echo -->

<!--#echo json="package.json" key="description" -->
Trying to build a streamlink wheel for armv7l (armhf) on GitHub Actions.
<!--/#echo -->


Roadmap
-------

* [x] Set up build process <del>that yields a streamlink wheel</del>
  for the same architecture as we're building on. That way, I could build
  it on the target machine itself, even if it takes much longer there.
* [x] Use docker's `--platform` option to make x86_64 docker
  build <ins>in</ins> an armhf <del>wheel</del><ins>container</ins>.
* [x] Make the armhf build work on GitHub Actions.






<!--#toc stop="scan" -->


&nbsp;


Known issues
------------

* Needs better docs.




&nbsp;


License
-------
<!--#echo json="package.json" key=".license" -->
ISC
<!--/#echo -->
