/**
 * DGC PRMS — Navigation UX helpers
 * - Shows a modern loading overlay while navigating between pages
 *   (this app uses classic full-page loads, not a SPA router).
 * - Persists the sidebar scroll position across page loads so the
 *   sidebar stays where the user left it when a link is clicked.
 */
(function () {
  'use strict';

  /* ── Page loading overlay ─────────────────────────────────── */
  var loader = document.getElementById('pageLoader');
  var loaderBar = document.getElementById('pageLoaderBar');
  var loaderTimer = null;

  function showLoader() {
    if (loader) loader.classList.add('is-active');
    if (loaderBar) {
      loaderBar.classList.remove('is-done');
      // restart the width transition
      void loaderBar.offsetWidth;
      loaderBar.classList.add('is-active');
    }
  }

  function hideLoader() {
    if (loader) loader.classList.remove('is-active');
    if (loaderBar) {
      loaderBar.classList.add('is-done');
      loaderBar.classList.remove('is-active');
    }
    if (loaderTimer) {
      clearTimeout(loaderTimer);
      loaderTimer = null;
    }
  }

  // Hide the loader once the new page has fully rendered.
  window.addEventListener('pageshow', hideLoader);
  document.addEventListener('DOMContentLoaded', hideLoader);

  function isSameOriginNavigation(link) {
    if (!link || !link.href) return false;
    if (link.target && link.target !== '' && link.target !== '_self') return false;
    if (link.hasAttribute('download')) return false;
    if (link.dataset && (link.dataset.bsToggle || link.dataset.noLoader !== undefined)) return false;
    var href = link.getAttribute('href') || '';
    if (href === '' || href.charAt(0) === '#') return false;
    if (href.indexOf('javascript:') === 0 || href.indexOf('mailto:') === 0 || href.indexOf('tel:') === 0) return false;
    try {
      var url = new URL(link.href, window.location.href);
      if (url.origin !== window.location.origin) return false;
      // Same-page anchor navigation shouldn't show the loader.
      if (url.pathname === window.location.pathname && url.search === window.location.search && url.hash) return false;
    } catch (e) {
      return false;
    }
    return true;
  }

  document.addEventListener('click', function (e) {
    if (e.defaultPrevented || e.button !== 0 || e.metaKey || e.ctrlKey || e.shiftKey || e.altKey) return;
    var link = e.target.closest('a[href]');
    if (isSameOriginNavigation(link)) {
      showLoader();
      // Safety net in case navigation is cancelled or takes too long.
      loaderTimer = setTimeout(hideLoader, 8000);
    }
  });

  document.addEventListener('submit', function (e) {
    var form = e.target;
    if (!(form instanceof HTMLFormElement)) return;
    if (form.dataset && form.dataset.noLoader !== undefined) return;
    showLoader();
    loaderTimer = setTimeout(hideLoader, 8000);
  });

  window.addEventListener('beforeunload', showLoader);

  /* ── Sidebar scroll position persistence ──────────────────── */
  var sidebar = document.getElementById('sidebarMenu');
  if (sidebar) {
    var SCROLL_KEY = 'prms.sidebarScrollTop';

    var saveTimer = null;
    function persistScroll() {
      sessionStorage.setItem(SCROLL_KEY, String(sidebar.scrollTop));
    }
    sidebar.addEventListener('scroll', function () {
      if (saveTimer) window.clearTimeout(saveTimer);
      saveTimer = window.setTimeout(persistScroll, 100);
    }, { passive: true });

    sidebar.addEventListener('click', persistScroll, true);
    window.addEventListener('pagehide', persistScroll);
    window.addEventListener('beforeunload', persistScroll);
  }
})();
