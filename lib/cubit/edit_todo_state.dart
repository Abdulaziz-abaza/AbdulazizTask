abstract class EditTodoState {}

class EditTodoInitial extends EditTodoState {}

class EditTodoLoading extends EditTodoState {}

class EditTodoLoaded extends EditTodoState {}

class EditTodoSuccess extends EditTodoState {}

class EditTodoError extends EditTodoState {
  final String message;
  EditTodoError(this.message);
}
