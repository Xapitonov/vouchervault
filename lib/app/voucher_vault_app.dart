import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vouchervault/app/app.dart';
import 'package:vouchervault/auth/auth_bloc.dart';
import 'package:vouchervault/auth/auth_screen.dart';
import 'package:vouchervault/models/voucher.dart';
import 'package:vouchervault/vouchers/voucher_iterator.dart';
import 'package:vouchervault/vouchers/vouchers.dart';

part 'voucher_vault_app.g.dart';

final routeObserver = RouteObserver<ModalRoute>();

@swidget
Widget voucherVaultApp(
  BuildContext context, {
  IList<Voucher>? vouchers,
  List<Override> overrides = const [],
}) =>
    ProviderScope(
      overrides: [
        ...overrides,
        /* if (vouchers != null) */
        /*   voucherIteratorProvider.overrideWithValue( */
        /*       voucherIterator(initialValue: VouchersState(vouchers))), */
      ],
      child: _App(),
    );

@hcwidget
Widget _app(WidgetRef ref) {
  // Remove expired vouchers
  final iterator = ref.watch(voucherIteratorProvider);
  useEffect(() {
    iterator.add(removeExpiredVouchers());
  }, [iterator]);

  // Auth state
  final authState = ref.watch(authBlocProvider);

  return MaterialApp(
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    home: authState.when(
      unauthenticated: () => AuthScreen(),
      authenticated: (_) => VouchersScreen(),
    ),
    navigatorObservers: [routeObserver],
  );
}
