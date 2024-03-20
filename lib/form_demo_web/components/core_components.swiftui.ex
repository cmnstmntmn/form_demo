defmodule FormDemoWeb.CoreComponents.SwiftUI do
  use FormDemoNative, [:component, format: :swiftui]

  @doc type: :component
  attr(:for, :any, required: true, doc: "An existing form or the form source data.")

  attr(:action, :string,
    doc: """
    The action to submit the form on.
    This attribute must be given if you intend to submit the form to a URL without LiveView.
    """
  )

  attr(:as, :atom,
    doc: """
    The prefix to be used in names and IDs generated by the form.
    For example, setting `as: :user_params` means the parameters
    will be nested "user_params" in your `handle_event` or
    `conn.params["user_params"]` for regular HTTP requests.
    If you set this option, you must capture the form with `:let`.
    """
  )

  attr(:csrf_token, :any,
    doc: """
    A token to authenticate the validity of requests.
    One is automatically generated when an action is given and the method is not `get`.
    When set to `false`, no token is generated.
    """
  )

  attr(:errors, :list,
    doc: """
    Use this to manually pass a keyword list of errors to the form.
    This option is useful when a regular map is given as the form
    source and it will make the errors available under `f.errors`.
    If you set this option, you must capture the form with `:let`.
    """
  )

  attr(:method, :string,
    doc: """
    The HTTP method.
    It is only used if an `:action` is given. If the method is not `get` nor `post`,
    an input tag with name `_method` is generated alongside the form tag.
    If an `:action` is given with no method, the method will default to `post`.
    """
  )

  attr(:multipart, :boolean,
    default: false,
    doc: """
    Sets `enctype` to `multipart/form-data`.
    Required when uploading files.
    """
  )

  attr(:rest, :global,
    include: ~w(autocomplete name rel enctype novalidate target),
    doc: "Additional HTML attributes to add to the form tag."
  )

  slot(:inner_block, required: true, doc: "The content rendered inside of the form tag.")

  def form(assigns) do
    action = assigns[:action]

    # We require for={...} to be given but we automatically handle nils for convenience
    form_for =
      case assigns[:for] do
        nil -> %{}
        other -> other
      end

    form_options =
      assigns
      |> Map.take([:as, :csrf_token, :errors, :method, :multipart])
      |> Map.merge(assigns.rest)
      |> Map.to_list()

    # Since FormData may add options, read the actual options from form
    %{options: opts} = form = to_form(form_for, form_options)

    # By default, we will ignore action, method, and csrf token
    # unless the action is given.
    attrs =
      if action do
        {method, opts} = Keyword.pop(opts, :method)
        {method, _} = form_method(method)

        [action: action, method: method] ++ opts
      else
        opts
      end

    attrs =
      case Keyword.pop(attrs, :multipart, false) do
        {false, attrs} -> attrs
        {true, attrs} -> Keyword.put(attrs, :enctype, "multipart/form-data")
      end

    assigns =
      assign(assigns,
        form: form,
        attrs: attrs
      )

    ~LVN"""
    <LiveForm {@attrs}>
      <%= render_slot(@inner_block, @form) %>
    </LiveForm>
    """
  end

  defp form_method(nil), do: {"post", nil}
  defp form_method(method) when method in ~w(get post), do: {method, nil}
  defp form_method(method) when is_binary(method), do: {"post", method}

  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file hidden month number password
               range radio search select tel text textarea time url week)

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  slot :inner_block

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "ColorPicker"} = assigns) do
    ~LVN"""
      <ColorPicker></ColorPicker>
    """
  end

  def input(%{type: "DatePicker"} = assigns) do
    ~LVN"""
      <DatePicker></DatePicker>
    """
  end

  def input(%{type: "MultiDatePicker"} = assigns) do
    ~LVN"""
      <MultiDatePicker></MultiDatePicker>
    """
  end

  def input(%{type: "Picker"} = assigns) do
    ~LVN"""
    <Picker></Picker>
    """
  end

  def input(%{type: "SecureField"} = assigns) do
    ~LVN"""
    <SecureField></SecureField>
    """
  end

  def input(%{type: "Slider"} = assigns) do
    ~LVN"""
    <Slider></Slider>
    """
  end

  def input(%{type: "Stepper"} = assigns) do
    ~LVN"""
    <Stepper></Stepper>
    """
  end

  def input(%{type: "TextEditor"} = assigns) do
    ~LVN"""
    <TextEditor></TextEditor>
    """
  end

  def input(%{type: "TextField"} = assigns) do
    ~LVN"""
    <TextField></TextField>
    """
  end

  def input(%{type: "Toggle"} = assigns) do
    ~LVN"""
    <Toggle></Toggle>
    """
  end

  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)

  slot :inner_block, required: true
  def button(assigns) do
    ~LVN"""
    <Button></Button>
    """
  end

  def table(assigns) do
    ~LVN"""
    <Table></Table>
    """
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # However the error messages in our forms and APIs are generated
    # dynamically, so we need to translate them by calling Gettext
    # with our gettext backend as first argument. Translations are
    # available in the errors.po file (as we use the "errors" domain).
    if count = opts[:count] do
      Gettext.dngettext(FormDemoWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(FormDemoWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end
end
