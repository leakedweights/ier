package src.env.agrobots;

import jason.asSyntax.*;
import jason.environment.*;
import jason.asSyntax.parser.*;

import java.util.logging.*;

public class FarmEnvironment extends Environment {

    private Logger logger = Logger.getLogger("agrobots." + FarmEnvironment.class.getName());

    @Override
    public void init(String[] args) {
        super.init(args);
        try {
            addPercept(ASSyntax.parseLiteral("percept(" + args[0] + ")"));
        } catch (ParseException e) {
            e.printStackTrace();
        }
    }

    @Override
    public boolean executeAction(String agName, Structure action) {
        logger.info("executing: " + action + ", but not implemented!");
        if (true) {
            informAgsEnvironmentChanged();
        }
        return true;
    }

    @Override
    public void stop() {
        super.stop();
    }
}
