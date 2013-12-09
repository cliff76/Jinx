Jinx
=========

Jinx is a prototype iPhone chat application which was originally developed as part of a one week interview exercise. During development a virtual sprint was conducted in which I planned the project, estimated the effort, wrote unit tests and delivered an overall product to my hiring engineering manager who was acting as the product owner. It has been a while sine the project has seen an update but I am now attempting to recode the app using iOS7 features.

The original app was written using iOS 4 and can still be run in that environment, use 

```sh
git clone https://github.com/cliff76/Jinx.git 
```

to checkout and build the app under an ios6 and below environment. If you wish to see the ongoing ios7 work run 

```sh
git checkout ios7Mods
```


immediately after cloning to build in the latest version of XCode.

Jinx is a chat app which features very rudimentary artificial intelligence. Select a chat buddy to begin an IM conversation. It showcases my work with Core Audio and audio sessions using pseudo TTS along with some basic video features. You can simulate a video call with any of the artificial chat buddies which loads a call screen that supports a video preview and TV Out. The chat buddy will talk using audio pre-generated from OpenMary TTS.

Work in progress
---
  - updating to use storyboard
  - fix broken animations and splash screen
  - Update the documentation
