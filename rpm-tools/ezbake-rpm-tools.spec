#   Copyright (C) 2013-2014 Computer Sciences Corporation
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

# Ordinarily, we include EzBake macro definitions by including
# %{_rpmconfigdir}/macros.ezbake into our spec. Because this RPM provides those
# macros, use the local copy instead.
%include %{_sourcedir}/macros.ezbake

Name:		ezbake-rpm-tools
Version:	%{ezbake_version}
Release:	%{ezbake_release}%{?dist}
Summary:	Tools to help build RPM packages on the EzBake platform

BuildArch:	noarch
Group:		Development/Tools
License:	ASL 2.0

# We can't keep listing individual files as sources forever, but until we get
# more than a few, this is OK
Source0:	macros.ezbake

Requires:	%{_rpmconfigdir}


%description
This package provides tools related to building RPM packages on the EzBake
platform.


%prep
cp %{_sourcedir}/macros.ezbake %{_builddir}
ls -l %{_builddir}


%build
mkdir -p %{buildroot}/%{_rpmconfigdir}
install -m 644 %{_builddir}/macros.ezbake %{buildroot}/%{_rpmconfigdir}


%files
%defattr(0755,root,root)
%attr(0755,root,root) %{_rpmconfigdir}/macros.ezbake


%changelog
* Tue Jan 20 2015 Charles Simpson <csimpson@42six.com> 2.1-SNAPSHOT
- initial commit
