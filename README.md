# Local running step (VSCode)
Step 1:

Download docker, and install `Dev containers` extension on VSCode

Step 2: 

```
ctrl + shift + p
Dev containers: Open Folder in container
``` 


Step 3:
```
bundle install
bundle exec jekyll serve --livereload
```

# Issue encountered in the build

1. VSCode shows error `Dev Container Configuration '.devcontainer/devcontainer.json' file already exists.`

    Check [Solution](https://github.com/microsoft/vscode-remote-release/issues/9303)

# Resource
[Youtube - BillRaymond](https://www.youtube.com/watch?v=zijOXpZzdvs&list=PLWzwUIYZpnJuT0sH4BN56P5oWTdHJiTNq)