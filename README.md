
# Twim

Twim is a twitter image downloader.  
When downloading, prefix account name into image file.

# Build

**requirements**
- Emscripten
- Nim (testing on devel branch of Github)
  - nimble
  - nake

```sh
$ nimble install nake
$ nake install-depends
$ nake build
```
