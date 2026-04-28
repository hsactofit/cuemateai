# Bugs And Risks

- `swift test` currently reports "no tests found" because the package has no test target yet.
- `product.html` may reference `dist/Cuemate.app`, which is only valid if local build artifacts or release assets are available.
