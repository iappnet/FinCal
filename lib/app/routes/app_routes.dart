part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const mainapp = _Paths.mainapp;
  static const home = _Paths.home;
  static const salaryCalculation = _Paths.salaryCalculation;
  static const history = _Paths.history;
  static const calculationDetails = _Paths.calculationDetails;
  static const settings = _Paths.settings;
  static const investmentCalculation = _Paths.investmentCalculation;
  static const loanCalculation = _Paths.loanCalculation;
}

abstract class _Paths {
  _Paths._();
  static const mainapp = '/';
  static const home = '/home';
  static const salaryCalculation = '/salary-calculation';
  static const history = '/history';
  static const calculationDetails = '/calculation-details';
  static const settings = '/settings';
  static const investmentCalculation = '/investment-calculation';
  static const loanCalculation = '/loan-calculation';
}
