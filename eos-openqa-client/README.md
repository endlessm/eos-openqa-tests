The following two files need to be manually synced from eos-image-builder, as
we can’t do a narrow clone with a submodule to only get the lib/ subdirectory
from eos-image-builder. Also, eos-image-builder is private but eos-openqa-tests
is public.

 * eibimageserver.py
 * eibopenqaserver.py
