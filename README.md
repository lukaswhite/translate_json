# Translate JSON

Translation tool for JSON-based language files.

Given the following:

```json
{
    "auth": {
        "login": {
            "page": {
                "title": "Log in to your account"
            },
            "form": {
                "fields": {
                    "email": {
                        "label": "Email address",
                        "hint": "Please enter your email address"
                    },
                    "password": {
                        "label": "Password",
                        "hint": "Please enter your password"
                    }
                }
            },
            "errors": {
                "invalid_credentials": "The email / password combination could not be found."
            }
        }
    }    
}
```

Enter the following command:

```bash
translate_json samples/en.json es --pretty-print
```

...to get this:

```json
{
     "auth": {
          "login": {
               "page": {
                    "title": "Ingrese a su cuenta"
               },
               "form": {
                    "fields": {
                         "email": {
                              "label": "Dirección de correo electrónico",
                              "hint": "Por favor, introduzca su dirección de correo electrónico"
                         },
                         "password": {
                              "label": "Contraseña",
                              "hint": "Por favor, introduzca su contraseña"
                         }
                    }
               },
               "errors": {
                    "invalid_credentials": "No se pudo encontrar la combinación de correo electrónico / contraseña."
               }
          }
     }
}
```

## Usage

```bash
translate_json <source> <language>
```

### Examples

Convert `samples/en.json` into Spanish, save to current directory (`de.json`).

```bash
translate_json ./samples/en.json es
```

Convert `samples/en.json` into German, save to the `translations` directory, replace it if it already exists and format it.

```bash
translate_json ./samples/en.json es --output-dir=translations --pretty-print
```

### Options

`--output-dir` / `-o` to specify the output language. Defaults to the current working directory.

`--source-language` / `-s` to specify the language of the source (e.g. `en`); this is optional.

### Flags

`--replace` / `-r` to replace the file if it exists; otherwise you will be prompted whether to overwrite it.

`--pretty-print` / `-p` to format the generated JSON.

## Roadmap

* Batch translations (e.g. YAML)
* Refactor
* Better error handling