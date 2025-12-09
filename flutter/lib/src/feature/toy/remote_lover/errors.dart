class RemoteLoverError {
  final String message;
  const RemoteLoverError(this.message);

  static const connectionNotFound = RemoteLoverError('Wrong code');
  static const connectionAlreadyOccupied = RemoteLoverError('This connection is already joined by another person');
  static const connectionIsBeingJoinedByAnother = RemoteLoverError('Another person is trying to join this connection');
  static const connectionRejected = RemoteLoverError('The connection was rejected by the other party');
}
