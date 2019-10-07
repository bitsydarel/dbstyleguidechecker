void main() {
  List.generate(10, (index) => SomeConstClass(7))
      .map((some) => print(some.immutableNumber));

  final as_sdf34 = "bad viarable name and unsued";

  // should be awaited
  runAndForget();

  final String kingLongName = "dhbahsdhbashfhsdvhfvahsvhvdhfasvfhvasfhvhvahsvdhahsvf";
}

Future runAndForget() {
  return Future.value(56);
}

class SomeConstClass {
  const SomeConstClass(this.immutableNumber);

  final int immutableNumber;
}
