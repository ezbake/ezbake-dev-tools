package ezbake.protect.mock.server;

import ezbake.base.thrift.*;
import ezbake.security.test.MockEzSecurityToken;
import ezbake.security.thrift.*;
import org.apache.thrift.TException;
import org.apache.thrift.TProcessor;

import java.util.Set;

/**
 * User: jhastings
 * Date: 6/3/14
 * Time: 11:35 AM
 */
public class EzSecurityMockService extends EzBakeBaseThriftService implements EzSecurity.Iface {
    @Override
    public TProcessor getThriftProcessor() {
        return new EzSecurity.Processor(this);
    }

    @Override
    public EzSecurityToken requestToken(TokenRequest tokenRequest, String s) throws EzSecurityTokenException, AppNotRegisteredException, TException {
        return getTestEzSecurityToken();
    }

    @Override
    public EzSecurityToken refreshToken(TokenRequest tokenRequest, String s) throws EzSecurityTokenException, AppNotRegisteredException, TException {
        return tokenRequest.getTokenPrincipal();
    }

    @Override
    public boolean isUserInvalid(EzSecurityToken ezSecurityToken, String s) throws EzSecurityTokenException, TException {
        return false;
    }

    @Override
    public ProxyTokenResponse requestProxyToken(ProxyTokenRequest proxyTokenRequest) throws EzSecurityTokenException, UserNotFoundException, TException {
        return null;
    }

    @Override
    public EzSecurityTokenJson requestUserInfoAsJson(TokenRequest tokenRequest, String s) throws EzSecurityTokenException, TException {
        return null;
    }

    @Override
    public boolean updateEzAdmins(Set<String> strings) throws TException {
        return false;
    }

    @Override
    public void invalidateCache(EzSecurityToken ezSecurityToken) throws EzSecurityTokenException, TException {

    }

    public static EzSecurityToken getTestEzSecurityToken() {
        return getTestEzSecurityToken(false);
    }

    public static EzSecurityToken getTestEzSecurityToken(boolean admin) {
        return getTestEzSecurityToken(admin, "dn");
    }

    public static EzSecurityToken getTestEzSecurityToken(boolean admin, String dn) {
        return MockEzSecurityToken.getMockEzSecurityToken("SecurityClientTest", "SecurityClientTest", dn, null, null,
                null, "high", null, null, TokenType.USER, 2600, true, false);
    }
}
