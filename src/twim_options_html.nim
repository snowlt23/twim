
import templates

let importBootstrap = """
<script src="jquery.min.js"></script>
<link rel="stylesheet" href="bootstrap.min.css">
<link rel="stylesheet" href="bootstrap-theme.min.css">
<script src="bootstrap.min.js"></script>
"""

proc genOptionPage*(): string =
  html(lang="ja"):
    head:
      meta(charset="UTF-8")
      title: "Twim Settings"
      importBootstrap
    body:
      d(class="panel panel-default", style="margin: 20px;"):
        d(class="panel-heading"):
          img(src="icon-enable.png", style="width: 32px; height: 32px; float: left; margin: 7px;")
          span(style="font-size: 32px;"): "Twim Settings"
        d(class="panel-body"):
          h3: "保存先:"
          d(class="input-group"):
            span(class="input-group-addon"): "~/ダウンロード/"
            input(id="save-directory", class="form-control", `type`="text")
          br
          input(id="save-settings", `type`="button", class="btn btn-success", value="設定を保存")
          span(id="save-status", style="margin: 5px;")
      script(src="twim-options.js")

writeFile("dist/twim-options.html", genOptionPage())
