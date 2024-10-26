
<!--#echo json="package.json" key="name" underline="=" -->
streamlink-build-armv7l-wheel
=============================
<!--/#echo -->

<!--#echo json="package.json" key="description" -->
Trying to build a streamlink wheel for armv7l (armhf) on GitHub Actions.
<!--/#echo -->


Roadmap
-------

* [ ] Set up build process that yields a streamlink wheel for the same
  architecture as we're building on. That way, I could build it on the
  target machine itself, even if it takes much longer there.
* [ ] Try and use docker's `--platform` option to make x86_64 docker
  build an armhf wheel.
* [ ] Try and make it the armhf build work on GitHub Actions.






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
