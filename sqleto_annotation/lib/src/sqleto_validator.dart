enum SQLetoValidator {
  emailValidator(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?"),
  usernameValidator(r"^[a-zA-Z0-9_]{5,24}$"),
  emptyValidator('');

  final String command;

  const SQLetoValidator(this.command);
}
