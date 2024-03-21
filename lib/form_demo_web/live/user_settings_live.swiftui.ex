defmodule FormDemoWeb.UserSettingsLive.SwiftUI do
  use FormDemoNative, [:render_component, format: :swiftui]

  import FormDemoWeb.CoreComponents.SwiftUI

  alias FormDemo.Accounts

  def render(assigns) do
    ~LVN"""
    <.header>
      Account Settings
      <:subtitle>Manage your account email address and password settings</:subtitle>
    </.header>

    <Form>
      <.form
        for={@email_form}
        id="email_form"
        phx-submit="update_email"
        phx-change="validate_email"
      >
        <Section>
          <Text template="header">Change Email</Text>
          <.input field={@email_form[:email]} type="TextField" label="Email" required />
          <.input
            field={@email_form[:current_password]}
            name="current_password"
            id="current_password_for_email"
            type="SecureField"
            label="Current password"
            value={@email_form_current_password}
            required
          />
        </Section>
        <Section>
          <.button type="submit">Change Email</.button>
        </Section>
      </.form>
      <.form
        for={@password_form}
        id="password_form"
        action={~p"/users/log_in?_action=password_updated"}
        method="post"
        phx-change="validate_password"
        phx-submit="update_password"
        phx-trigger-action={@trigger_submit}
      >
        <Section>
          <Text template="header">Change Password</Text>
          <.input
            field={@password_form[:email]}
            type="hidden"
            id="hidden_user_email"
            value={@current_email}
            readonly
          />
          <.input field={@password_form[:password]} type="SecureField" label="New password" required />
          <.input
            field={@password_form[:password_confirmation]}
            type="SecureField"
            label="Confirm new password"
          />
          <.input
            field={@password_form[:current_password]}
            name="current_password"
            type="SecureField"
            label="Current password"
            id="current_password_for_password"
            value={@current_password}
            required
          />
        </Section>

        <Section>
          <.button type="submit">Change Password</.button>
        </Section>
      </.form>
    </Form>
    """
  end
end
