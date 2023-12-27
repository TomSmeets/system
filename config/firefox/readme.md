# How I configure Firefox

- [uBlock Origin](https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/)
- [Sponsor Block](https://addons.mozilla.org/en-US/firefox/addon/sponsorblock/)
- [Tree Style Tab](https://addons.mozilla.org/en-US/firefox/addon/tree-style-tab/)
- [Dark Reader](https://addons.mozilla.org/en-US/firefox/addon/darkreader/)
- [Stylus](https://addons.mozilla.org/en-US/firefox/addon/styl-us/)

## Tree Style tabs
Go to `about:config` and set `toolkit.legacyUserProfileCustomizations.stylesheets` to true.

- <https://superuser.com/questions/1424478/can-i-hide-native-tabs-at-the-top-of-firefox>

```css
#TabsToolbar {
  visibility: collapse;
}
```

## Stylus
Any extension that allows adding custom stylesheets will do.
