package ezbake.protect.mock.server;

import ezbake.base.thrift.EzBakeBaseThriftService;
import ezbake.base.thrift.EzSecurityToken;
import ezbake.security.thrift.*;
import org.apache.thrift.TException;
import org.apache.thrift.TProcessor;

import java.util.List;
import java.util.Set;

/**
 * User: jhastings
 * Date: 6/3/14
 * Time: 8:35 AM
 */
public class EzSecurityRegistrationMockService extends EzBakeBaseThriftService implements EzSecurityRegistration.Iface {
    @Override
    public String registerApp(EzSecurityToken ezSecurityToken, String s, String s2, List<String> strings, List<String> communityAuths, String s3, Set<String> strings2, String s4) throws TException {
        return null;
    }

    @Override
    public void promote(EzSecurityToken ezSecurityToken, String s) throws TException {

    }

    @Override
    public void denyApp(EzSecurityToken ezSecurityToken, String s) throws TException {

    }

    @Override
    public void deleteApp(EzSecurityToken ezSecurityToken, String s) throws RegistrationException, SecurityIDNotFoundException, PermissionDeniedException, TException {

    }

    @Override
    public void demote(EzSecurityToken ezSecurityToken, String s) throws TException {

    }

    @Override
    public void update(EzSecurityToken ezSecurityToken, ApplicationRegistration applicationRegistration) throws TException {

    }

    @Override
    public ApplicationRegistration getRegistration(EzSecurityToken ezSecurityToken, String s) throws TException {
        return null;
    }

    @Override
    public RegistrationStatus getStatus(EzSecurityToken ezSecurityToken, String s) throws TException {
        return null;
    }

    @Override
    public List<ApplicationRegistration> getRegistrations(EzSecurityToken ezSecurityToken) throws TException {
        return null;
    }

    @Override
    public List<ApplicationRegistration> getAllRegistrations(EzSecurityToken ezSecurityToken, RegistrationStatus registrationStatus) throws TException {
        return null;
    }

    @Override
    public AppCerts getAppCerts(EzSecurityToken ezSecurityToken, String s) throws TException {
        AppCerts appCerts = new AppCerts();
        appCerts.setEzbakesecurityservice_pub("Public Key".getBytes());
        appCerts.setApplication_crt("Application Cert".getBytes());
        appCerts.setApplication_p12("App P12".getBytes());
        appCerts.setApplication_pub("Application Public Key".getBytes());
        appCerts.setApplication_priv("Application Private Key".getBytes());
        appCerts.setApplication_crt("Application certificate".getBytes());
        appCerts.setEzbakeca_crt("CA Cert".getBytes());
        appCerts.setEzbakeca_jks("CA JKS".getBytes());

        return appCerts;
    }

    @Override
    public void addAdmin(EzSecurityToken ezSecurityToken, String s, String s2) throws TException {

    }

    @Override
    public void removeAdmin(EzSecurityToken ezSecurityToken, String s, String s2) throws TException {

    }

    @Override
    public boolean ping() {
        return true;
    }

    @Override
    public TProcessor getThriftProcessor() {
        return new EzSecurityRegistration.Processor(this);
    }

}
