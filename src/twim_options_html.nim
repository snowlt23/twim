
import templates

let importBootstrap = """
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css" integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous">
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>
"""

proc genOptionPage*(): string =
  html(lang="ja"):
    head:
      title: "Twim Settings"
      importBootstrap
    body:
      d(class="panel panel-default", style="margin: 20px"):
        d(class="panel-heading"):
          h1: "Twim Settings"
        d(class="panel-body"):
          h3: "Save Directory:"
          d(class="input-group"):
            span(class="input-group-addon"): "~/Downloads/"
            input(id="save-directory", class="form-control", `type`="text")
          br
          input(id="save-settings", `type`="button", class="btn btn-success", value="Save Settings")
      script(src="twim-options.js")

writeFile("dist/twim-options.html", genOptionPage())
