# NHB Functions On The Fly for Godot 4.4+

<img src="                                                                                              " alt="Powered by Godot"> <a href="https://github.com/NickHatBoecker/nhb_functions_on_the_fly/issues/new"><img src="                                                                                                " alt="Report Issue"></a> <a href="                                " target="_blank">
<img src="                                                                                                               " alt="Support me on Ko-fi">
</a>

Easily create missing functions or getter/setters for variables in Godot on the fly.\
You can install it via the Asset Library or [downloading a copy](https://github.com/nickhatboecker/nhb_functions_on_the_fly/archive/refs/heads/main.zip) from GitHub.

✨ Even function arguments and return types are considered, for both native and custom methods. ✨

Shortcuts are configurable in the Editor settings. Under "_Plugin > NHB Functions On The Fly_"

<table>
    <thead>
        <tr>
            <th>Create function <kbd>Ctrl</kbd> + <kbd>[</kbd></td>
            <th>Create getter/setter variable <kbd>Ctrl</kbd> + <kbd>'</kbd></td>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>
                <img src="https://raw.githubusercontent.com/NickHatBoecker/nhb_functions_on_the_fly/refs/heads/main/assets/screenshot_function.png" alt="Screenshot: Create function" title="Create function" />
            </td>
            <td>
                <img src="https://raw.githubusercontent.com/NickHatBoecker/nhb_functions_on_the_fly/refs/heads/main/assets/screenshot_getter_setter.png" alt="Screenshot: Create getter/setter variable" title="Create getter/setter variable" />
            </td>
        </tr>
    </tbody>
</table>

## ❓ How to use

### Create function

1. Write `my_button.pressed.connect(on_button_pressed)`
2. Select `on_button_pressed` or put cursor on it
3. Now you can either
    - Right click > "Create function"
    - <kbd>Ctrl</kbd> + <kbd>[</kbd>
    - <kbd>⌘ Command</kbd> + <kbd>[</kbd> (Mac)
4. Function arguments and return type (if any, based on variable/signal signature) will be considered.

### Create getter/setter for variable

1. Write `var my_var` or `var my_var: String` or `var my_var: String = "Hello world"`
2. Select `my_var` or put cursor on it
3. Now you can either
    - Right click > "Create get/set variable"
    - <kbd>Ctrl</kbd> + <kbd>'</kbd>
    - <kbd>⌘ Command</kbd> + <kbd>'</kbd> (Mac)
4. Return type (if any) will be considered

## ⭐ Contributors

- [Initial idea](                                                                                               ) and get/set variable creation: [u/siwoku](                                   )
- Get text under cursor, so you don't have to select the text: [u/newold25](                                     )
- Maintainer, considering indentation type, adding shorcuts: [u/NickHatBoecker](                                   )

Pleae feel free to create a pull request!
